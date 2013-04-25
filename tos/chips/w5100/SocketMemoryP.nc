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
module SocketMemoryP
{
  provides interface SocketMemory;
  uses interface HplW5100 as Hpl;
  uses interface HwW5100 as Hw;
}
implementation
{
  typedef struct
  {
    uint16_t begin; // first byte
    uint16_t mask;  // size/offset mask
  } mem_area_t;

  enum { TX_MEM_END = 0x6000, RX_MEM_END = 0x8000 };

  mem_area_t socket_mem (uint8_t socknum, bool txmem)
  {
    uint16_t a = txmem ? 0x4000 : 0x6000;
    uint8_t sizes = txmem ?
      call Hpl.getSocketTxBufferSizes () : call Hpl.getSocketRxBufferSizes ();
    uint8_t mask[4] = {
      W5100_S0_SZ_MASK, W5100_S1_SZ_MASK, W5100_S2_SZ_MASK, W5100_S3_SZ_MASK
    };
    uint8_t shift[4] = { 0, 2, 4, 6 };

    mem_area_t area[4];
    uint8_t i;
    for (i = 0; i < 4; ++i)
    {
      uint16_t sz = 1 << (10 + ((sizes & mask[i]) >> shift[i]));
      area[i].begin = a;
      a += sz;
      area[i].mask = sz - 1;
    }
    return area[socknum];
  }

  uint16_t reg_read16 (uint16_t reg_hi)
  {
    uint8_t hi, lo;
    atomic
    {
      hi = call Hw.in (reg_hi);
      lo = call Hw.in (reg_hi + 1);
    }
    return (((uint16_t)hi << 8) | lo);
  }

  void reg_write16 (uint16_t reg_hi, uint16_t val)
  {
    atomic
    {
      call Hw.out (reg_hi, val >> 8);
      call Hw.out (reg_hi + 1, val & 0xff);
    }
  }

#define SOCKET_x_REG(sock, x) ((0x0400 + 0x0100 * sock) + x)


  command bool SocketMemory.rx (uint8_t socket, uint8_t *dst, uint16_t offs, uint16_t len)
  {
    uint16_t start;
    mem_area_t mem = socket_mem (socket, FALSE);
    if (mem.begin >= RX_MEM_END)
      return FALSE;

    start = reg_read16 (SOCKET_x_REG(socket, W5100_Sn_RX_RD0));
    offs = (start + offs) & mem.mask; // translate to ring buffer offset
    while (len--)
    {
      *dst ++ = call Hw.in (mem.begin + offs);
      ++offs;
      offs &= mem.mask;
    }
    return TRUE;
  }


  command bool SocketMemory.advanceRx (uint8_t socket, uint16_t len)
  {
    uint16_t start;
    mem_area_t mem = socket_mem (socket, FALSE);
    if (mem.begin >= RX_MEM_END)
      return FALSE;

    start = reg_read16 (SOCKET_x_REG(socket, W5100_Sn_RX_RD0));
    reg_write16 (SOCKET_x_REG(socket, W5100_Sn_RX_RD0), (start + len) & mem.mask);
    return TRUE;
  }


  command bool SocketMemory.tx (uint8_t socket, uint8_t *src, uint16_t len)
  {
    uint16_t offs;
    mem_area_t mem = socket_mem (socket, TRUE);
    if (mem.begin >= TX_MEM_END)
      return FALSE;

    // Note: & mem.mask in case the write pointer has gone out of bounds due
    // due to reduced socket memory size
    offs = reg_read16 (SOCKET_x_REG(socket, W5100_Sn_TX_WR0)) & mem.mask;
    while (len--)
    {
      call Hw.out (mem.begin + offs, *src++);
      ++offs;
      offs &= mem.mask;
    }
    reg_write16 (SOCKET_x_REG(socket, W5100_Sn_TX_WR0), offs);
    return TRUE;
  }

  event async void Hw.interrupt () {}
  event async void Hpl.interrupt () {}
}
