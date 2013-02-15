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
module IPv4NetworkShellCmdC
{
  provides interface ShellExecute;
  uses interface ShellOutput;
  uses interface IPv4Network;
}
implementation
{
  in_addr_t parse_arg (const char *arg)
  {
    in_addr addr;
    unsigned a = 0, b = 0, c = 0, d = 0;
    sscanf (arg, "%u.%u.%u.%u", &a, &b, &c, &d);
    addr.s_addr8[0] = a;
    addr.s_addr8[1] = b;
    addr.s_addr8[2] = c;
    addr.s_addr8[3] = d;
    return addr.s_addr;
  }

  const char *format_addr (in_addr_t a)
  {
    static char buf[19];
    in_addr addr;
    addr.s_addr = a;
    sprintf (buf, "%d.%d.%d.%d\r\n",
      addr.s_addr8[0], addr.s_addr8[1], addr.s_addr8[2],  addr.s_addr8[3]);
    return buf;
  }

#define ip4net_func(what) \
  error_t do ## what (const char *arg) \
  { \
    error_t ret; \
    if (arg) \
    { \
      ret = call IPv4Network.set ## what (parse_arg (arg)); \
      if (ret == SUCCESS) \
        signal ShellExecute.executeDone (SUCCESS); \
      return ret; \
    } \
    else \
    { \
      in_addr_t addr; \
      const char *s; \
      ret = call IPv4Network.get ## what (&addr); \
      s = format_addr (addr); \
      return ret == SUCCESS ? call ShellOutput.output (s, strlen (s)) : ret; \
    } \
  }

  ip4net_func(Address)
  ip4net_func(Gateway)
  ip4net_func(SubnetMask)

  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    enum { CMD_ADDR, CMD_GW, CMD_MASK, CMD_NONE } cmd = CMD_NONE;
    const char *arg = (argc > 2) ? argv[2] : NULL;

    if (argc >= 2)
    {
      if (strcmp ("addr", argv[1]) == 0)
        cmd = CMD_ADDR;
      else if (strcmp ("gw", argv[1]) == 0)
        cmd = CMD_GW;
      else if (strcmp ("mask", argv[1]) == 0)
        cmd = CMD_MASK;
    }

    switch (cmd)
    {
      case CMD_ADDR: return doAddress (arg);
      case CMD_GW:   return doGateway (arg);
      case CMD_MASK: return doSubnetMask (arg);
      default: break;
    }
    return FAIL;
  }

  command void ShellExecute.abort () {}

  event void ShellOutput.outputDone ()
  {
    signal ShellExecute.executeDone (SUCCESS);
  }
}
