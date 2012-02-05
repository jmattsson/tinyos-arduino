/*
 * Copyright (c) 2012 Johny Mattsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <avr/power.h>

module Atm328pUsartP
{
  provides
  {
    interface StdControl;
    interface UartStream;
    interface UartByte;
    interface UartError;
    interface SerialFlush;
  }
  uses
  {
    interface Init            as HplUsartInit;
    interface HplAtm328pUsart as HplUsart;
    interface StdControl      as HplRxControl;
    interface StdControl      as HplTxControl;
    interface BusyWait<TMicro, uint16_t>;
    interface Atm328pUsartConfig;
    interface HplAtm328pPower as HplPower;
    interface McuPowerState;
  }
}
implementation
{
  struct {
    uint8_t *buf;
    uint16_t len;
    uint16_t idx;
  } tx, rx;

  bool byte_receive_enabled = FALSE;

  bool notify_flush = FALSE;


  bool receive_with_error_notify (uint8_t *dst)
  {
    bool overrun = FALSE;

    if (call HplUsart.dataOverrun ())
      overrun = TRUE;

    if (call HplUsart.frameError () || call HplUsart.parityError ())
    {
      signal UartError.receiveError ();
      return FALSE;
    }

    *dst = call HplUsart.rx ();

    // only signal after we've recovered the byte from the data register
    if (overrun)
      signal UartError.receiveError ();

    return TRUE;
  }

#define USART_POWER_CHECK() \
  do { \
    if (!call HplPower.isUsartPowered ()) \
      return EOFF; \
  } while (0)

////// UartError /////////////////////////////////////////////////////

  default async event void UartError.receiveError () {}


////// StdControl ////////////////////////////////////////////////////

  command error_t StdControl.start ()
  {
    error_t res;

    if (call HplPower.isUsartPowered ())
      return SUCCESS; // already started

    call StdControl.stop ();

    power_usart0_enable ();

    res = call HplUsartInit.init ();
    if (res != SUCCESS)
      return res;

    call HplTxControl.start ();
    call HplRxControl.start ();

    call McuPowerState.update ();

    return SUCCESS;
  }

  command error_t StdControl.stop ()
  {
    if (!call HplPower.isUsartPowered ())
      return SUCCESS; // already stopped

    atomic {
      if (tx.buf)
      {
        signal UartStream.sendDone (tx.buf, tx.len, FAIL);
        tx.buf = 0;
      }
      if (rx.buf)
      {
        signal UartStream.receiveDone (rx.buf, rx.len, FAIL);
        rx.buf = 0;
      }

      // Note: we don't care about an outstanding flush request; If that's in
      // use, they should know better than the shut down the chip early!

      call HplUsart.disableDreInterrupt ();
      call HplUsart.disableTxcInterrupt ();
      call HplUsart.disableRxcInterrupt ();

      call HplRxControl.stop ();
      call HplTxControl.stop ();

      power_usart0_disable ();
      call McuPowerState.update ();

      return SUCCESS;
    }
  }

////// UartStream ////////////////////////////////////////////////////

  async command error_t UartStream.send (uint8_t *buf, uint16_t len)
  {
    USART_POWER_CHECK();
    atomic {
      if (tx.buf)
        return FAIL;

      tx.buf = buf;
      tx.len = len;
      tx.idx = 0;

      call HplUsart.enableDreInterrupt ();
    }
    return SUCCESS;
  }


  async command error_t UartStream.enableReceiveInterrupt ()
  {
    USART_POWER_CHECK();
    atomic {
      if (rx.buf)
        return FAIL;
      byte_receive_enabled = TRUE;
      call HplUsart.enableRxcInterrupt ();
    }
    return SUCCESS;
  }


  async command error_t UartStream.disableReceiveInterrupt ()
  {
    USART_POWER_CHECK();
    atomic {
      if (!byte_receive_enabled)
        return FAIL;
      byte_receive_enabled = FALSE;
      call HplUsart.disableRxcInterrupt ();
    }
    return SUCCESS;
  }


  async command error_t UartStream.receive (uint8_t *buf, uint16_t len)
  {
    USART_POWER_CHECK();
    atomic {
      if (rx.buf || byte_receive_enabled)
        return FAIL;

      rx.buf = buf;
      rx.len = len;
      rx.idx = 0;

      call HplUsart.enableRxcInterrupt ();
    }
    return SUCCESS;
  }


  default async event void UartStream.sendDone (uint8_t *buf, uint16_t len, error_t result) {}

  default async event void UartStream.receiveDone (uint8_t *buf, uint16_t len, error_t result) {}

  default async event void UartStream.receivedByte (uint8_t byte) {}


////// UartByte //////////////////////////////////////////////////////

  async command error_t UartByte.send (uint8_t byte)
  {
    USART_POWER_CHECK();
    if (!call HplUsart.txEmpty ())
      return FAIL;

    // Should we disable the Tx/Dre interrupts while using UartByte.send() ?
    call HplUsart.tx (byte);
    while (!call HplUsart.txEmpty ()) {}
    return SUCCESS;
  }


  async command error_t UartByte.receive (uint8_t *byte, uint8_t timeout)
  {
    uint8_t symbols;
    uint16_t symbol_time;
    uint32_t total_wait;

    atm328p_usart_config_t *cfg = call Atm328pUsartConfig.getConfig ();

    USART_POWER_CHECK();
    if (!cfg)
      return FAIL;

    symbol_time = 1000000ul / cfg->baud;

    symbols = 1; // start bit
    switch (cfg->bits)
    {
      case ATM328P_USART_BITS_5: symbols += 5; break;
      case ATM328P_USART_BITS_6: symbols += 6; break;
      case ATM328P_USART_BITS_7: symbols += 7; break;
      case ATM328P_USART_BITS_8: symbols += 8; break;
      case ATM328P_USART_BITS_9: symbols += 9; break;
    }
    symbols += cfg->parity == ATM328P_USART_PARITY_NONE ? 0 : 1;
    symbols += cfg->two_stop_bits ? 2 : 1;

    total_wait = symbol_time * symbols * timeout;

    while (!call HplUsart.rxComplete ())
    {
      if (!total_wait)
        return FAIL;
      call BusyWait.wait (symbol_time);
      total_wait -= symbol_time;
    }
    return receive_with_error_notify (byte) ? SUCCESS : FAIL;
  }


////// SerialFlush ///////////////////////////////////////////////////

  task void do_notify_flush ()
  {
    signal SerialFlush.flushDone ();
  }


  command void SerialFlush.flush ()
  {
    if (!call HplPower.isUsartPowered ())
      return; // EOFF
    call HplUsart.enableTxcInterrupt ();
    atomic notify_flush = TRUE;
  }


  default event void SerialFlush.flushDone () {}


////// Interrupts ////////////////////////////////////////////////////

  async event void HplUsart.rxDone ()
  {
    atomic {
      uint8_t byte;
      if (!receive_with_error_notify (&byte))
        return;

      if (byte_receive_enabled)
        signal UartStream.receivedByte (byte);
      else if (rx.buf) {
        rx.buf[rx.idx++] = byte;
        if (rx.idx == rx.len)
        {
          uint8_t *buf = rx.buf;
          rx.buf = 0; // mark as done, so new receive can be done from signal
          call HplUsart.disableRxcInterrupt ();
          signal UartStream.receiveDone (buf, rx.len, SUCCESS);
        }
      }
      else
        call HplUsart.disableRxcInterrupt ();
    }
  }


  async event void HplUsart.txDone ()
  {
    atomic {
      call HplUsart.disableTxcInterrupt ();
      if (notify_flush && call HplUsart.txEmpty ())
      {
        notify_flush = FALSE;
        post do_notify_flush ();
      }
    }
  }


  async event void HplUsart.txNowEmpty ()
  {
    atomic {
      if (tx.buf && tx.idx != tx.len)
        call HplUsart.tx (tx.buf[tx.idx++]);
      else
      {
        call HplUsart.disableDreInterrupt ();
        if (tx.buf && tx.idx == tx.len)
        {
          uint8_t *buf = tx.buf;
          tx.buf = 0; // mark as done, so new send can be commenced from signal
          signal UartStream.sendDone (buf, tx.len, SUCCESS);
        }
      }
    }
  }

}
