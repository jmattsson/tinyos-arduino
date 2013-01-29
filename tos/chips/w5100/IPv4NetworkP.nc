/*
 * Copyright (c) 2012-2013 Johny Mattsson
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
module IPv4NetworkP
{
  provides interface IPv4Network;
  uses interface HplW5100 as Hpl;
  uses interface Resource;
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


  command error_t IPv4Network.setAddress (in_addr_t addr)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      call Hpl.setIPv4Address (addr);
      release (&r);
    }
    return res;
  }

  command error_t IPv4Network.getAddress (in_addr_t *addr)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
       *addr = call Hpl.getIPv4Address ();
       release (&r);
    }
    return res;
  }


  command error_t IPv4Network.setGateway (in_addr_t addr)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      call Hpl.setGateway (addr);
      release (&r);
    }
    return res;
  }

  command error_t IPv4Network.getGateway (in_addr_t *addr)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      *addr = call Hpl.getGateway ();
      release (&r);
    }
    return res;
  }


  command error_t IPv4Network.setSubnetMask (in_addr_t mask)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      call Hpl.setSubnetMask (mask);
      release (&r);
    }
    return res;
  }

  command error_t IPv4Network.getSubnetMask (in_addr_t *mask)
  {
    resource_t r;
    error_t res = claim (&r);
    if (res == SUCCESS)
    {
      *mask = call Hpl.getSubnetMask ();
      release (&r);
    }
    return res;
  }


  event void Resource.granted (void) {}
  async event void Hpl.interrupt () {}
}
