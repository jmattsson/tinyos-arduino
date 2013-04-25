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

interface IPv4UdpSocket
{
  /**
   * Binds the socket to the specified port number and starts listening
   * for packets.
   *
   * @param port The port number to bind to. Must be non-zero.
   * @return SUCCESS if successful.
   */
  command error_t bind (in_port_t port);

  /**
   * Sends a payload to the specified destination.
   *
   * @param addr The destination address.
   * @param port The destination port.
   * @param payload The data to send, MUST NOT be null.
   * @param len The length, in bytes, from @c payload to send.
   * @return SUCCESS if no error was encountered while beginning the send.
   */
  command error_t sendto (in_addr_t addr, in_port_t port, void *payload, uint16_t len);

  /**
   * Gather-read version of sendto.
   *
   * @param addr The destination address.
   * @param port The destination port.
   * @param iov I/O chain with the data to gather and send.
   * @return SUCCESS if no error was encountered while beginning the send.
   */
  command error_t sendtov (in_addr_t addr, in_port_t port, in_iovec *iov);

  /**
   * Signalled when new data has arrived.
   * In response to this, the receiver MUST consume ALL the data, either using
   * @c read() or @c skip(). Failure to do so results in the unconsumed data
   * appearing at the start of the next received message.
   *
   * Note that this is may be signalled with interrupts disabled, so
   * long-running processing in response to this is discouraged.
   *
   * @param len The number of bytes in the message.
   */
  async event void msg (uint16_t len);

  /**
   * Reads (consumes) received data.
   * Attempts to read more data than has been received yields undefined
   * behaviour.
   *
   * @param out Destination buffer, MUST be at least @c len bytes in size.
   * @param len Number of bytes to read.
   * @return SUCCESS if the data was available and could be read.
   */
  command error_t read (void *out, uint16_t len);

  /**
   * Reads (but doesn't consume) received data.
   * Attempts to read more data than has been received yields undefined
   * behaviour.
   *
   * @param out Destination buffer, MUST be at least @c len bytes in size.
   * @param offs The offset to peek at/from.
   * @param len Number of bytes to read.
   * @return SUCCESS if the data was available and could be read.
   */
  command error_t peek (void *out, uint16_t offs, uint16_t len);

  /**
   * Skips (consumes) received data.
   * Can be used to ignore received data without having to load it into memory
   * first.  Attempts to skip more data than has been received yields undefined
   * behaviour.
   *
   * @param len The number of bytes to skip.
   * @return SUCCESS if successful.
   */
  command error_t skip (uint16_t len);
}
