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
#include "w5100.h"

generic module HplW5100SocketC(uint8_t sock_num)
{
  provides interface HplW5100Socket;
  uses
  {
    interface HwW5100 as Hw;
    interface HplW5100; // for interrupt
  }
}
implementation
{

#define SOCKET_n_REG(x) ((0x0400 + 0x0100 * sock_num) + x)

  void reg_or8 (uint16_t reg, uint8_t val)
  {
    atomic 
    {
      val |= call Hw.in (SOCKET_n_REG(reg));
      call Hw.out (SOCKET_n_REG(reg), val);
    }
  }

  void reg_mask8 (uint16_t reg, uint8_t val)
  {
    atomic 
    {
      val = ~val;
      val &= call Hw.in (SOCKET_n_REG(reg));
      call Hw.out (SOCKET_n_REG(reg), val);
    }
  }

  uint8_t reg_read8 (uint16_t reg)
  {
    return call Hw.in (SOCKET_n_REG(reg));
  }

  void reg_write8 (uint16_t reg, uint8_t val)
  {
    call Hw.out (SOCKET_n_REG(reg), val);
  }

  uint16_t reg_read16 (uint16_t reg_hi)
  {
    uint8_t hi, lo;
    atomic
    {
      hi = reg_read8 (reg_hi);
      lo = reg_read8 (reg_hi+1);
    }
    return ((uint16_t)(hi << 8) | lo);
  }

  void reg_write16 (uint16_t reg_hi, uint16_t val)
  {
    atomic
    {
      reg_write8 (reg_hi, val >> 8);
      reg_write8 (reg_hi + 1, val & 0xff);
    }
  }


  async command void HplW5100Socket.enableMulticast ()
  {
    reg_or8 (W5100_Sn_MR, W5100_Sn_MR_MULTI);
  }

  async command void HplW5100Socket.disableMulticast ()
  {
    reg_mask8 (W5100_Sn_MR, W5100_Sn_MR_MULTI);
  }

  async command bool HplW5100Socket.getMulticast ()
  {
    return (reg_read8 (W5100_Sn_MR) & W5100_Sn_MR_MULTI);
  }


  async command void HplW5100Socket.enablePromiscuousMode ()
  {
    // enable promisc == disable mac filter
    reg_mask8 (W5100_Sn_MR, W5100_Sn_MR_MF);
  }

  async command void HplW5100Socket.disablePromiscuousMode ()
  {
    reg_or8 (W5100_Sn_MR, W5100_Sn_MR_MF);
  }

  async command bool HplW5100Socket.getPromiscuousMode ()
  {
    return !(reg_read8 (W5100_Sn_MR) & W5100_Sn_MR_MF);
  }


  async command void HplW5100Socket.enableDelayedAck ()
  {
    // enable delayed ack == disable non-delayed ack *sigh*
    reg_mask8 (W5100_Sn_MR, W5100_Sn_MR_NDMC);
  }

  async command void HplW5100Socket.disableDelayedAck ()
  {
    reg_or8 (W5100_Sn_MR, W5100_Sn_MR_NDMC);
  }

  async command bool HplW5100Socket.getDelayedAck ()
  {
    return !(reg_read8(W5100_Sn_MR) & W5100_Sn_MR_NDMC);
  }


  async command void HplW5100Socket.setIgmpV1 ()
  {
    reg_or8 (W5100_Sn_MR, W5100_Sn_MR_NDMC);
  }

  async command void HplW5100Socket.setIgmpV2 ()
  {
    reg_mask8 (W5100_Sn_MR, W5100_Sn_MR_NDMC);
  }


  async command void HplW5100Socket.setProtocol (uint8_t proto)
  {
    atomic
    {
      uint8_t mr = reg_read8 (W5100_Sn_MR);
      mr &= ~W5100_Sn_MR_PROTO_MASK;
      mr |= (proto & W5100_Sn_MR_PROTO_MASK);
      reg_write8 (W5100_Sn_MR, mr);
    }
  }

  async command uint8_t HplW5100Socket.getProtocol ()
  {
    return (reg_read8 (W5100_Sn_MR) & W5100_Sn_MR_PROTO_MASK);
  }

 
  async command void HplW5100Socket.executeCommand (uint8_t code)
  {
    reg_write8 (W5100_Sn_CR, code);
  }


  async command uint8_t HplW5100Socket.getInterruptFlags ()
  {
    return reg_read8 (W5100_Sn_IR);
  }

 
  async command uint8_t HplW5100Socket.getStatus ()
  {
    return reg_read8 (W5100_Sn_SR);
  }


  async command void HplW5100Socket.setSrcPort (in_port_t port)
  {
    reg_write16 (W5100_Sn_PORT0, port);
  }


  async command in_port_t HplW5100Socket.getSrcPort ()
  {
    return reg_read16 (W5100_Sn_PORT0);
  }


  async command void HplW5100Socket.setDstMacAddress (mac_addr_t mac)
  {
    reg_write8 (W5100_Sn_DHAR0, mac.s_addr8[0]);
    reg_write8 (W5100_Sn_DHAR1, mac.s_addr8[1]);
    reg_write8 (W5100_Sn_DHAR2, mac.s_addr8[2]);
    reg_write8 (W5100_Sn_DHAR3, mac.s_addr8[3]);
    reg_write8 (W5100_Sn_DHAR4, mac.s_addr8[4]);
    reg_write8 (W5100_Sn_DHAR5, mac.s_addr8[5]);
  }

  async command mac_addr_t HplW5100Socket.getDstMacAddress ()
  {
    mac_addr_t mac;
    mac.s_addr8[0] = reg_read8 (W5100_Sn_DHAR0);
    mac.s_addr8[1] = reg_read8 (W5100_Sn_DHAR1);
    mac.s_addr8[2] = reg_read8 (W5100_Sn_DHAR2);
    mac.s_addr8[3] = reg_read8 (W5100_Sn_DHAR3);
    mac.s_addr8[4] = reg_read8 (W5100_Sn_DHAR4);
    mac.s_addr8[5] = reg_read8 (W5100_Sn_DHAR5);
    return mac;
  }


  async command void HplW5100Socket.setDstIPv4Address (in_addr_t addr)
  {
    in_addr ia = { addr };
    reg_write8 (W5100_Sn_DIPR0, ia.s_addr8[0]);
    reg_write8 (W5100_Sn_DIPR1, ia.s_addr8[1]);
    reg_write8 (W5100_Sn_DIPR2, ia.s_addr8[2]);
    reg_write8 (W5100_Sn_DIPR3, ia.s_addr8[3]);
  }

  async command in_addr_t HplW5100Socket.getDstIPv4Address ()
  {
    in_addr ia;
    ia.s_addr8[0] = reg_read8 (W5100_Sn_DIPR0);
    ia.s_addr8[1] = reg_read8 (W5100_Sn_DIPR1);
    ia.s_addr8[2] = reg_read8 (W5100_Sn_DIPR2);
    ia.s_addr8[3] = reg_read8 (W5100_Sn_DIPR3);
    return ia.s_addr;
  }


  async command void HplW5100Socket.setDstPort (in_port_t port)
  {
    reg_write16 (W5100_Sn_DPORT0, port);
  }

  async command in_port_t HplW5100Socket.getDstPort ()
  {
    return reg_read16 (W5100_Sn_DPORT0);
  }


  async command void HplW5100Socket.setMss (uint16_t mss)
  {
    reg_write16 (W5100_Sn_MSSR0, mss);
  }

  async command uint16_t HplW5100Socket.getMss ()
  {
    return reg_read16 (W5100_Sn_MSSR0);
  }


  async command void HplW5100Socket.setIpRawProtocol (uint8_t ip_proto)
  {
    reg_write8 (W5100_Sn_PROTO, ip_proto);
  }

  async command uint8_t HplW5100Socket.getIpRawProtocol ()
  {
    return reg_read8 (W5100_Sn_PROTO);
  }


  async command void HplW5100Socket.setTypeOfService (uint8_t tos)
  {
    reg_write8 (W5100_Sn_TOS, tos);
  }

  async command uint8_t HplW5100Socket.getTypeOfService ()
  {
    return reg_read8 (W5100_Sn_TOS);
  }


  async command void HplW5100Socket.setTimeToLive (uint8_t ttl)
  {
    reg_write8 (W5100_Sn_TTL, ttl);
  }

  async command uint8_t HplW5100Socket.getTimeToLive ()
  {
    return reg_read8 (W5100_Sn_TTL);
  }


  async command uint16_t HplW5100Socket.getTxFreeSize ()
  {
    return reg_read16 (W5100_Sn_TX_FSR0);
  }


  async command uint16_t HplW5100Socket.getTxReadOffs ()
  {
    return reg_read16 (W5100_Sn_TX_RD0);
  }


  async command void HplW5100Socket.setTxWriteOffs (uint16_t offs)
  {
    reg_write16 (W5100_Sn_TX_WR0, offs);
  }

  async command uint16_t HplW5100Socket.getTxWriteOffs ()
  {
    return reg_read16 (W5100_Sn_TX_WR0);
  }


  async command uint16_t HplW5100Socket.getRxSize ()
  {
    return reg_read16 (W5100_Sn_RX_RSR0);
  }


  async command void HplW5100Socket.setRxReadOffs (uint16_t offs)
  {
    reg_write16 (W5100_Sn_RX_RD0, offs);
  }

  async command uint16_t HplW5100Socket.getRxReadOffs ()
  {
    return reg_read16 (W5100_Sn_RX_RD0);
  }


  async event void HplW5100.interrupt ()
  {
    atomic
    {
      uint8_t flags = call HplW5100.getInterruptFlags ();
      uint8_t my_flag = 1 << sock_num;
      if (flags & my_flag)
        signal HplW5100Socket.interrupt ();
    }
  }

  async event void Hw.interrupt () {} // We use the HPL rather than the raw H/W
  default async event void HplW5100Socket.interrupt () {}
}
