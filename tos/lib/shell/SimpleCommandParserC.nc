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

generic module SimpleCommandParserC()
{
  provides interface ShellCommandParser;
}
implementation
{

  #ifndef SIMPLE_COMMAND_PARSER_BUF_SIZE
  #define SIMPLE_COMMAND_PARSER_BUF_SIZE 128
  #endif

  #ifndef SIMPLE_COMMAND_PARSER_MAX_ARGS
  #define SIMPLE_COMMAND_PARSER_MAX_ARGS 9
  #endif

  enum { ABORT_KEY = 0x03 }; // ctrl-c

  char recv_buf[SIMPLE_COMMAND_PARSER_BUF_SIZE] = { 0 };
  char *rx = recv_buf;

  uint8_t argc;
  const char *argv[SIMPLE_COMMAND_PARSER_MAX_ARGS +1];

  bool buffer_locked = FALSE;

  task void request_abort ()
  {
    signal ShellCommandParser.abortRequested ();
  }

  task void parse_command ()
  {
    char *p;
    bool escaped = FALSE, inquote = FALSE, inspace = FALSE;

    argc = 0;
    memset (argv, 0, sizeof(argv));
    argv[argc++] = recv_buf;

    for (p = recv_buf; *p && argc <= SIMPLE_COMMAND_PARSER_MAX_ARGS; ++p)
    {
      if (escaped)
      {
        escaped = FALSE;
        continue;
      }
      if (*p == ' ' && !inquote && !escaped)
      {
        inspace = TRUE;
        *p = 0;
        continue;
      }
      if (inspace && !escaped && *p != ' ')
      {
        inspace = FALSE;
        argv[argc++] = p;
        continue;
      }
      if (*p == '\\')
      {
        escaped = TRUE;
        continue;
      }
      if (*p == '"')
      {
        inquote = TRUE;
        continue;
      }
    }

    if (escaped || inquote || *p)
    {
      call ShellCommandParser.releaseArgs ();
      signal ShellCommandParser.parseFailed ();
    }
    else
      signal ShellCommandParser.parseCompleted (argc, argv);
  }


  command void ShellCommandParser.releaseArgs ()
  {
    atomic {
      rx = recv_buf;
      *rx = 0;
      buffer_locked = FALSE;
    }
  }

  async command void ShellCommandParser.inputByte (uint8_t byte)
  {
    atomic {

      if (byte == ABORT_KEY)
      {
        rx = recv_buf;
        post request_abort ();
        return;
      }

      if (!buffer_locked && (byte == '\r' || byte == '\n'))
      {
        *rx = 0;
        buffer_locked = TRUE;
        post parse_command ();
        return;
      }

      if (byte < ' ' || byte == 0x7f)
      {
        switch (byte)
        {
          case 0x08: // Backspace
          case 0x7f: // Delete
            if (rx > recv_buf)
              --rx;
            break;
          case 0x15: // ctrl-u
            rx = recv_buf;
            break;
          default: break;
        }
        return;
      }

      if (!buffer_locked && (rx < (recv_buf + sizeof(recv_buf) -1)))
        *rx++ = byte;
    }
  }

}
