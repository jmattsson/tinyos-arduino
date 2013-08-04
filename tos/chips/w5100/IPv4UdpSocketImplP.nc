/*
 * Copyright (c) 2013 Johny Mattsson
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

#include "w5100.h"
#include "Wiznet5100.h"

module IPv4UdpSocketImplP
{
  provides interface IPv4UdpSocket[uint8_t sock_no];
  uses
  {
    interface HplW5100Socket[uint8_t sock_no];
    interface SocketMemory;
    interface Resource;
  }
}
implementation
{
  typedef struct
  {
    bool ours;
  } resource_t;

  error_t claim (resource_t *r)
  {
    error_t res = SUCCESS;
    bool pre_owned = call Resource.isOwner ();
    if (pre_owned)
      r->ours = FALSE;
    else
    {
      res = call Resource.immediateRequest ();
      r->ours = (res == SUCCESS);
    }
    return res;
  }

  void release (resource_t *r)
  {
    if (r->ours)
      call Resource.release ();
    r->ours = FALSE;
  }


  error_t sendtov (uint8_t sock_no, in_addr_t addr, in_port_t port, in_iovec *iov)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      // TODO: would be nice to keep track against free tx mem...
      bool write_ok = TRUE;
      while (iov)
      {
        write_ok &= call SocketMemory.tx (sock_no, iov->data, iov->len);
        iov = iov->next;
      }
      call HplW5100Socket.executeCommand[sock_no] (W5100_Sn_CR_SEND);
      // Can we do this nicer than a hard loop somehow?
      while (!call HplW5100Socket.commandDone[sock_no] ()) {}
      release (&r);
    }
    return res;
  }


  command error_t IPv4UdpSocket.bind[uint8_t sock_no] (in_port_t port)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      call HplW5100Socket.setProtocol[sock_no] (W5100_Sn_MR_PROTO_UDP);
      call HplW5100Socket.setSrcPort[sock_no] (port);
      call HplW5100Socket.executeCommand[sock_no] (W5100_Sn_CR_OPEN);
      res = (call HplW5100Socket.getStatus[sock_no] () == W5100_Sn_SR_SOCK_UDP)
        ? SUCCESS : FAIL;
      call HplW5100Socket.enableInterrupt[sock_no] (res == SUCCESS);
      release (&r);
    }
    return res;
  }


  command error_t IPv4UdpSocket.sendto[uint8_t sock_no] (in_addr_t addr, in_port_t port, void *payload, uint16_t len)
  {
    in_iovec iov = { payload, len, NULL };
    return sendtov (sock_no, addr, port, &iov);
  }


  command error_t IPv4UdpSocket.sendtov[uint8_t sock_no] (in_addr_t addr, in_port_t port, in_iovec *iov)
  {
    return sendtov (sock_no, addr, port, iov);
  }


  command error_t IPv4UdpSocket.read[uint8_t sock_no] (void *out, uint16_t len)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      bool ok = call SocketMemory.rx (sock_no, out, 0, len);
      ok &= call SocketMemory.advanceRx (sock_no, len);
      res = ok ? SUCCESS : FAIL;
      release (&r);
    }
    return res;
  }


  command error_t IPv4UdpSocket.peek[uint8_t sock_no] (void *out, uint16_t offs, uint16_t len)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      res = call SocketMemory.rx (sock_no, out, offs, len) ? SUCCESS : FAIL;
      release (&r);
    }
    return res;
  }


  command error_t IPv4UdpSocket.skip[uint8_t sock_no] (uint16_t len)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      res = call SocketMemory.advanceRx (sock_no, len) ? SUCCESS : FAIL;
      release (&r);
    }
    return res;
  }



  async event void HplW5100Socket.interrupt[uint8_t sock_no] ()
  {
    uint8_t flags = call HplW5100Socket.getInterruptFlags[sock_no] ();
    if (flags & W5100_Sn_IR_SEND_OK)
      ;
    if (flags & W5100_Sn_IR_TIMEOUT)
      ;
    if (flags & W5100_Sn_IR_RECV)
    {
      uint16_t rxlen = call HplW5100Socket.getRxSize[sock_no] ();
      signal IPv4UdpSocket.msg[sock_no] (rxlen);
    }
  }

  event void Resource.granted () {}

  default async event void IPv4UdpSocket.msg[uint8_t sock_no] (uint16_t len) {}
}
