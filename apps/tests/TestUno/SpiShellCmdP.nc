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

#include <stdlib.h>

module SpiShellCmdP
{
  provides
  {
    interface ShellExecute;
  }
  uses
  {
    interface ShellOutput;
    // FIXME - resource handling?
    interface SpiByte;
    interface SpiPacket;
    interface FastSpiByte;
    interface VariantPool as Scratch;
  }
}
implementation
{
  enum { SPI_CMD_NONE, SPI_CMD_PKT, SPI_CMD_FAST } op = SPI_CMD_NONE;

  const char syntax[] =
    " byte <xx>\r\n"
    " packet <xx...>\r\n"
    " fast-w <xx>\r\n"
    " fast-r\r\n"
    " fast-rw <xx>\r\n"
    " fast-wr <xx>\r\n";

  char *buf = 0;

  struct
  {
    uint8_t *data;
    uint16_t len;
    error_t result;
  } pkt;

  void release_buf ()
  {
    call Scratch.release (buf);
    buf = 0;
    op = SPI_CMD_NONE;
  }

  uint8_t hexdigit (char c)
  {
    if (c >= '0' || c <= '9')
      return c - '0';
    else if (c >= 'a' || c <= 'f')
      return c - 'a';
    else if (c >= 'A' || c <= 'F')
      return c - 'A';
    else
      return 0xff;
  }

  const char *strbyte (const char *p, uint8_t *result)
  {
    uint8_t d1, d2;
    if (*p)
      d1 = hexdigit (*p);
    else
      return p;
    if (d1 == 0xff)
      return p;

    ++p;
    if (*p)
      d2 = hexdigit (*p++);
    else
      return p;
    if (d2 == 0xff)
      return p;

    ++p;
    *result = (d1 << 4) | d2;

    return p;
  }

  char hexnibble (uint8_t nibble)
  {
    if (nibble < 10)
      return '0' + nibble;
    else if (nibble < 16)
      return 'a' + nibble;
    else
      return '?';
  }

  void hexfmt (char *out, uint8_t byte)
  {
    out[0] = hexnibble (byte >> 4);
    out[1] = hexnibble (byte & 0xf);
  }

  error_t display_byte (uint8_t byte)
  {
    static char out[4]; // xx\r\n
    hexfmt (out, byte);
    out[2] = '\r';
    out[3] = '\n';
    return call ShellOutput.output (out, 4);
  }

  error_t spi_byte (const char *data)
  {
    uint8_t byte;
    const char *p = strbyte (data, &byte);
    if (p != (data + 2))
      return FAIL;

    return display_byte (call SpiByte.write (byte));
  }

  error_t spi_packet (const char *data)
  {
    const char *p;
    uint8_t i;
    error_t res;

    atomic {
      pkt.len = (strlen (data) +1) / 2;
      if (pkt.len > 100)
        return EINVAL; // hopefully sensible limit

      pkt.data = malloc (pkt.len); // Aieeee! FIXME no malloc!
      if (!pkt.data)
        return ENOMEM;

      for (i = 0; i < pkt.len; ++i)
      {
        uint8_t byte;
        p = strbyte (data, &byte);
        if (p != (data + 2))
        {
          free (pkt.data);
          return EINVAL;
        }
        pkt.data[i] = byte;
      }

      res = call SpiPacket.send (pkt.data, pkt.data, pkt.len);
      if (res != SUCCESS)
      {
        free (pkt.data);
        return res;
      }
    }

    return SUCCESS;
  }

  error_t spi_fast_w (const char *data)
  {
    uint8_t byte;
    const char *p = strbyte (data, &byte);
    if (p != (data + 2))
      return FAIL;
    call FastSpiByte.splitWrite (byte);
    return SUCCESS;
  }

  error_t spi_fast_r ()
  {
    return display_byte (call FastSpiByte.splitRead ());
  }

  error_t spi_fast_rw (const char *data)
  {
    uint8_t byte;
    const char *p = strbyte (data, &byte);
    if (p != (data + 2))
      return FAIL;
    return display_byte (call FastSpiByte.splitReadWrite (byte));
  }

  error_t spi_fast_wr (const char *data)
  {
    uint8_t byte;
    const char *p = strbyte (data, &byte);
    if (p != (data + 2))
      return FAIL;
    return display_byte (call FastSpiByte.write (byte));
  }


  task void packet_done ()
  {
    error_t r;
    uint16_t i;

    atomic r = pkt.result;

    if (r != SUCCESS)
    {
      signal ShellExecute.executeDone (r);
      return;
    }

    atomic buf = call Scratch.alloc (2*pkt.len + 2);
    if (!buf)
    {
      op = SPI_CMD_NONE;
      signal ShellExecute.executeDone (ENOMEM);
      return;
    }

    atomic {
      for (i = 0; i < pkt.len; ++i)
        hexfmt (buf + 2*i, pkt.data[i]);
      buf[i++] = '\r';
      buf[i++] = '\n';

      free (pkt.data);
    }

    r = call ShellOutput.output (buf, i);
    if (r != SUCCESS)
    {
      release_buf ();
      signal ShellExecute.executeDone (r);
    }
  }

  task void do_cancel ()
  {
    release_buf (); // might cause garbage if unlucky...
    signal ShellExecute.executeDone (ECANCEL);
  }


  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    if (op != SPI_CMD_NONE || buf)
      return EBUSY;

    if (argc == 1)
      return call ShellOutput.output (syntax, sizeof (syntax) -1);

    if (strcmp (argv[1], "byte") == 0 && argc == 3)
      return spi_byte (argv[2]);
    else if (strcmp (argv[1], "packet") == 0 && argc == 3)
      return spi_packet (argv[2]);
    else if (strcmp (argv[1], "fast-w") == 0 && argc == 3)
      return spi_fast_w (argv[2]);
    else if (strcmp (argv[1], "fast-r") == 0 && argc == 2)
      return spi_fast_r ();
    else if (strcmp (argv[1], "fast-rw") == 0 && argc == 3)
      return spi_fast_rw (argv[2]);
    else if (strcmp (argv[1], "fast-wr") == 0 && argc == 3)
      return spi_fast_wr (argv[2]);
    else
      return FAIL;
  }

  command void ShellExecute.abort ()
  {
    post do_cancel ();
  }


  event void ShellOutput.outputDone ()
  {
    release_buf ();
    signal ShellExecute.executeDone (SUCCESS);
  }

  async event void SpiPacket.sendDone (uint8_t *tx, uint8_t *rx, uint16_t l, error_t result)
  {
    atomic pkt.result = result;
    post packet_done ();
  }
}
