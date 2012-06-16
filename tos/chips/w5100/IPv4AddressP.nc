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
module IPv4AddressP
{
  provides interface IPv4Address;
  uses interface HplW5100 as Hpl;
}
implementation
{
  command void IPv4Address.setAddress (in_addr_t addr)
  {
    in_addr_t old;
    old = call Hpl.getIPv4Address ();
    if (old != addr)
    {
      call Hpl.setIPv4Address (addr);
      signal IPv4Address.changed ();
    }
  }

  command in_addr_t IPv4Address.getAddress ()
  {
    return call Hpl.getIPv4Address ();
  }


  command void IPv4Address.setGateway (in_addr_t addr)
  {
    call Hpl.setGateway (addr);
  }

  command in_addr_t IPv4Address.getGateway ()
  {
    return call Hpl.getGateway ();
  }


  command void IPv4Address.setSubnetMask (in_addr_t mask)
  {
    call Hpl.setSubnetMask (mask);
  }

  command in_addr_t IPv4Address.getSubnetMask ()
  {
    return call Hpl.getSubnetMask ();
  }


  async event void Hpl.interrupt () {}
}
