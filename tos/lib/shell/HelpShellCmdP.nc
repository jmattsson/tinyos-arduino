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

#include <stdio.h>

generic module HelpShellCmdP()
{
  provides interface ShellExecute;
  uses interface ShellOutput;
  uses interface ShellCommand[uint8_t id];
  uses interface VariantPool as Scratch;
}
implementation
{
  char *buf = 0;
  uint8_t id;

  enum { END_OF_HELP = 0xff };

  task void printHelp ()
  {
    size_t len = 0;
    char *p;
    int ret;
    error_t res;

    call Scratch.release (buf); // grab a larger buffer if available
    buf = p = call Scratch.reserve (&len);

    while (len)
    {
      const char *str = call ShellCommand.getCommandString[id] ();
      if (!str || !*str)
      {
        id = END_OF_HELP;
        break;
      }

      ret = snprintf (p, len, "%s\r\n", str);
      if (ret <= 0 || (ret > len))
        break;

      ++id;
      len -= ret;
      p += ret;
    }

    call Scratch.reduce (buf, p - buf);
    res = call ShellOutput.output (buf, p - buf);
    if (res != SUCCESS)
    {
      call Scratch.release (buf);
      signal ShellExecute.executeDone (res);
    }
  }

  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    if (buf)
      return EBUSY;

    id = 0;
    post printHelp ();

    return SUCCESS;
  }

  command void ShellExecute.abort () {}

  event void ShellOutput.outputDone ()
  {
    if (id != END_OF_HELP)
      post printHelp();
    else
    {
      call Scratch.release (buf);
      buf = 0;
      signal ShellExecute.executeDone (SUCCESS);
    }
  }
}
