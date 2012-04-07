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

#include "Wiznet5100.h"

module HplW5100C
{
  provides interface HplW5100;
  uses interface HwW5100 as Hw;
}
implementation
{

  void reg_or8 (uint16_t reg, uint8_t val)
  {
    val |= call Hw.in (reg);
    call Hw.out (reg, val);
  }

  void reg_mask8 (uint16_t reg, uint8_t val)
  {
    val = ~val;
    val &= call Hw.in (reg);
    call Hw.out (reg, val);
  }

  async command void HplW5100.reset ()
  {
    reg_or8 (W5100_MR, W5100_MR_RST);
  }


  async command void HplW5100.enablePingBlock ()
  {
    reg_or8 (W5100_MR, W5100_MR_PB);
  }

  async command void HplW5100.disablePingBlock ()
  {
    reg_mask8 (W5100_MR, W5100_MR_PB);
  }

  async command bool HplW5100.getPingBlock ()
  {
    return (call Hw.in (W5100_MR) & W5100_MR_PB);
  }


  async command void HplW5100.enablePPPoE ()
  {
    reg_or8 (W5100_MR, W5100_MR_PPPOE);
  }

  async command void HplW5100.disablePPPoE ()
  {
    reg_mask8 (W5100_MR, W5100_MR_PPPOE);
  }

  async command bool HplW5100.getPPPoE ()
  {
    return (call Hw.in (W5100_MR) & W5100_MR_PPPOE);
  }


  async command void HplW5100.enableAddressAutoInc ()
  {
    reg_or8 (W5100_MR, W5100_MR_AI);
  }

  async command void HplW5100.disableAddressAutoInc ()
  {
    reg_mask8 (W5100_MR, W5100_MR_AI);
  }

  async command bool HplW5100.getAddressAutoInc ()
  {
    return (call Hw.in (W5100_MR) & W5100_MR_AI);
  }


  async command void HplW5100.enableIndirectBusMode ()
  {
    reg_or8 (W5100_MR, W5100_MR_IND);
  }

  async command void HplW5100.disableIndirectBusMode ()
  {
    reg_mask8 (W5100_MR, W5100_MR_IND);
  }

  async command bool HplW5100.getIndirectBusMode ()
  {
    return (call Hw.in (W5100_MR) & W5100_MR_IND);
  }


  async command void HplW5100.setGateway (in_addr_t gw)
  {
    in_addr ia = { gw };
    call Hw.out (W5100_GAR0, ia.s_addr8[0]);
    call Hw.out (W5100_GAR1, ia.s_addr8[1]);
    call Hw.out (W5100_GAR2, ia.s_addr8[2]);
    call Hw.out (W5100_GAR3, ia.s_addr8[3]);
  }

  async command in_addr_t HplW5100.getGateway ()
  {
    in_addr ia;
    ia.s_addr8[0] = call Hw.in (W5100_GAR0);
    ia.s_addr8[1] = call Hw.in (W5100_GAR1);
    ia.s_addr8[2] = call Hw.in (W5100_GAR2);
    ia.s_addr8[3] = call Hw.in (W5100_GAR3);
    return ia.s_addr;
  }


  async command void HplW5100.setSubnetMask (in_addr_t mask)
  {
    in_addr ia = { mask };
    call Hw.out (W5100_SUBR0, ia.s_addr8[0]);
    call Hw.out (W5100_SUBR1, ia.s_addr8[1]);
    call Hw.out (W5100_SUBR2, ia.s_addr8[2]);
    call Hw.out (W5100_SUBR3, ia.s_addr8[3]);
  }

  async command in_addr_t HplW5100.getSubnetMask ()
  {
    in_addr ia;
    ia.s_addr8[0] = call Hw.in (W5100_SUBR0);
    ia.s_addr8[1] = call Hw.in (W5100_SUBR1);
    ia.s_addr8[2] = call Hw.in (W5100_SUBR2);
    ia.s_addr8[3] = call Hw.in (W5100_SUBR3);
    return ia.s_addr;
  }


  async command void HplW5100.setIPv4Address (in_addr_t addr)
  {
    in_addr ia = { addr };
    call Hw.out (W5100_SIPR0, ia.s_addr8[0]);
    call Hw.out (W5100_SIPR1, ia.s_addr8[1]);
    call Hw.out (W5100_SIPR2, ia.s_addr8[2]);
    call Hw.out (W5100_SIPR3, ia.s_addr8[3]);
  }

  async command in_addr_t HplW5100.getIPv4Address ()
  {
    in_addr ia;
    ia.s_addr8[0] = call Hw.in (W5100_SIPR0);
    ia.s_addr8[1] = call Hw.in (W5100_SIPR1);
    ia.s_addr8[2] = call Hw.in (W5100_SIPR2);
    ia.s_addr8[3] = call Hw.in (W5100_SIPR3);
    return ia.s_addr;
  }


  async command void HplW5100.setMacAddress (mac_addr_t addr)
  {
    call Hw.out (W5100_SHAR0, addr.s_addr8[0]);
    call Hw.out (W5100_SHAR1, addr.s_addr8[1]);
    call Hw.out (W5100_SHAR2, addr.s_addr8[2]);
    call Hw.out (W5100_SHAR3, addr.s_addr8[3]);
    call Hw.out (W5100_SHAR4, addr.s_addr8[4]);
    call Hw.out (W5100_SHAR5, addr.s_addr8[5]);
  }

  async command mac_addr_t HplW5100.getMacAddress ()
  {
    mac_addr_t mac;
    mac.s_addr8[0] = call Hw.in (W5100_SHAR0);
    mac.s_addr8[1] = call Hw.in (W5100_SHAR1);
    mac.s_addr8[2] = call Hw.in (W5100_SHAR2);
    mac.s_addr8[3] = call Hw.in (W5100_SHAR3);
    mac.s_addr8[4] = call Hw.in (W5100_SHAR4);
    mac.s_addr8[5] = call Hw.in (W5100_SHAR5);
    return mac;
  }


  async command void HplW5100.clearInterruptFlags (uint8_t flags)
  {
    call Hw.out (W5100_IR, flags);
  }

  async command uint8_t HplW5100.getInterruptFlags ()
  {
    return call Hw.in (W5100_IR);
  }


  async command void HplW5100.setInterruptMask (uint8_t mask)
  {
    call Hw.out (W5100_IMR, mask);
  }

  async command uint8_t HplW5100.getInterruptMask ()
  {
    return call Hw.in (W5100_IMR);
  }


  async command void HplW5100.setRetryInterval (uint16_t val)
  {
    call Hw.out (W5100_RTR0, val >> 8);
    call Hw.out (W5100_RTR1, val & 0xff);
  }

  async command uint16_t HplW5100.getRetryInterval ()
  {
    return (call Hw.in (W5100_RTR0) << 8) | (call Hw.in (W5100_RTR1));
  }


  async command void HplW5100.setRetryCount (uint8_t val)
  {
    call Hw.out (W5100_RCR, val);
  }

  async command uint8_t HplW5100.getRetryCount ()
  {
    return call Hw.in (W5100_RCR);
  }


  async command void HplW5100.setSocketRxBufferSizes (uint8_t rxms)
  {
    call Hw.out (W5100_RMSR, rxms);
  }

  async command uint8_t HplW5100.getSocketRxBufferSizes ()
  {
    return call Hw.in (W5100_RMSR);
  }


  async command void HplW5100.setSocketTxBufferSizes (uint8_t txms)
  {
    call Hw.out (W5100_TMSR, txms);
  }

  async command uint8_t HplW5100.getSocketTxBufferSizes ()
  {
    return call Hw.in (W5100_TMSR);
  }


  async command void HplW5100.setAuthType (bool pap)
  {
    uint16_t val = (pap ? W5100_PATR_PAP : W5100_PATR_CHAP);
    call Hw.out (W5100_PATR0, val >> 8);
    call Hw.out (W5100_PATR1, val & 0xff);
  }

  async command bool HplW5100.isAuthTypePap ()
  {
    uint16_t val =
      (call Hw.in (W5100_PATR0) << 8) | (call Hw.in (W5100_PATR1));
    return val == W5100_PATR_PAP;
  }


  async command void HplW5100.setLcpEchoInterval (uint8_t val)
  {
    call Hw.out (W5100_PTIMER, val);
  }

  async command uint16_t HplW5100.getLcpEchoInterval ()
  {
    return call Hw.in (W5100_PTIMER);
  }


  async command in_addr_t HplW5100.getLastUnreachableIPv4Address ()
  {
    in_addr ia;
    ia.s_addr8[0] = call Hw.in (W5100_UIPR0);
    ia.s_addr8[1] = call Hw.in (W5100_UIPR1);
    ia.s_addr8[2] = call Hw.in (W5100_UIPR2);
    ia.s_addr8[3] = call Hw.in (W5100_UIPR3);
    return ia.s_addr;
  }

  async command in_port_t HplW5100.getLastUnreachablePort ()
  {
    in_port_t port;
    port = (call Hw.in (W5100_UPORT0) << 8) | (call Hw.in (W5100_UPORT1));
    return port;
  }


  async event void Hw.interrupt ()
  {
    signal HplW5100.interrupt ();
  }
}
