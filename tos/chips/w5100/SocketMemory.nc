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
interface SocketMemory
{
  /**
   * Reads socket memory.
   * All access is relative to the current read position in the ring
   * buffer, and buffer wrap-around is handled internally.
   * E.g. if a packet has arrived and the read pointer is at X, calling
   *   read(sock, buf, 0, 8);
   * will read the first 8 bytes of the packet into the buffer.
   *
   * Note: Does NOT change the read position register.
   *
   * @param socket The socket number to read from (0-3).
   * @param dst The destination buffer. MUST be of at least size @c len bytes.
   * @param offs The offset from the <em>current read pointer</em>.
   * @param len The number of bytes to read.
   * @return True if the read succeeded, false if the socket has no memory
   *   allocated to it.
   */
  command bool rx (uint8_t socket, uint8_t *dst, uint16_t offs, uint16_t len);

  /**
   * Advances the read position of the socket memory.
   *
   * @param socket The socket number to advance the read position for (0-3).
   * @param len The number of bytes to advance it by.
   * @return True if the operation succeeded, false if not.
   */
  command bool advanceRx (uint8_t socket, uint16_t len);

  /**
   * Writes socket memory.
   * Automatically appends to the TX memory of the specified socket, and
   * updates the write position register.
   *
   * @param socket The socket number to write to (0-3).
   * @param src The source buffer.
   * @param len The number of bytes to write. If this value is greater than
   *   the current available TX memory, the behaviour is undefined.
   * @return True if the write is possible, false if the socket has no
   *   memory allocated to it.
   */
  command bool tx (uint8_t socket, uint8_t *src, uint16_t len);
}
