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
module EtherShellCmdP
{
  provides interface ShellExecute;
  uses interface ShellOutput;
  uses interface EtherAddress;
  uses interface VariantPool as Scratch;
}
implementation
{
  static char *buf = 0;

#define PRINT_BUF_SZ 19   /* xx:xx:xx:xx:xx:xx\r\n */

  error_t do_get (void)
  {
    int i;
    mac_addr_t mac;
    char *p;
    error_t res = call EtherAddress.getAddress (&mac);
    if (res != SUCCESS)
      return res;

    p = buf = call Scratch.alloc (PRINT_BUF_SZ);
    if (!buf)
      return ENOMEM;

    for (i = 0; i < sizeof (mac); ++i)
    {
      if (i)
        *p++ = ':';
      p += sprintf (p, "%02x", mac.s_addr8[i]);
    }
    *p++ = '\r';
    *p++ = '\n';

    res = call ShellOutput.output (buf, PRINT_BUF_SZ);
    if (res != SUCCESS)
    {
      call Scratch.release (buf);
      buf = 0;
    }
    return res;
  }

  error_t do_set (const char *arg)
  {
    unsigned a, b, c, d, e, f;
    if (sscanf (arg, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f) != 6)
      return EINVAL;
    {
      mac_addr_t mac = { { a, b, c, d, e, f } };
      error_t res = call EtherAddress.setAddress (mac);
      if (res == SUCCESS)
        signal ShellExecute.executeDone (SUCCESS);
    }
    return SUCCESS;
  }

  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    if (buf)
      return EBUSY;

    if (argc > 1)
      return do_set (argv[1]);
    else
      return do_get ();
  }

  command void ShellExecute.abort () {}

  event void ShellOutput.outputDone ()
  {
    call Scratch.release (buf);
    buf = 0;
    signal ShellExecute.executeDone (SUCCESS);
  }
}
