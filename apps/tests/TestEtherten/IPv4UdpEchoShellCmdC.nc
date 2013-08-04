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
module IPv4UdpEchoShellCmdC
{
  provides interface ShellExecute;
  uses interface ShellOutput;
  uses interface IPv4UdpSocket as Socket;
}
implementation
{

#define ECHO_PORT 7
#define MAX_ECHO_SIZE 128

  uint16_t pkt_len = 0;

  task void echo ();

  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    error_t res = call Socket.bind (ECHO_PORT);
    if (res == SUCCESS)
      signal ShellExecute.executeDone (SUCCESS);
    return res;
  }

  command void ShellExecute.abort () {}

  event void ShellOutput.outputDone () {}


  async event void Socket.msg (uint16_t len)
  {
    if (!pkt_len)
    {
      pkt_len = len;
//      post echo ();
    }
  }

  task void echo ()
  {
    in_addr_t peer_ip;
    in_port_t peer_port;
    uint16_t len;
    uint8_t data[MAX_ECHO_SIZE];
    uint16_t data_len;
    error_t res;

    atomic len = pkt_len;

    call ShellOutput.output ("pkt!\n", 5);

    res = call Socket.peek (&peer_ip, 0, 4);
    if (res != SUCCESS)
      goto out;

    res = call Socket.peek (&peer_port, 4, 2);
    if (res != SUCCESS)
      goto out;

    // Note: ignoring the len field - already know the total pkt length
    data_len = len - 8;
    if (data_len > MAX_ECHO_SIZE)
      data_len = MAX_ECHO_SIZE;

    res = call Socket.peek (&data, 8, data_len);
    if (res != SUCCESS)
      goto out;

    res = call Socket.sendto (peer_ip, peer_port, data, data_len);
out:
    call Socket.skip (len);
    atomic pkt_len = 0;
  }
}
