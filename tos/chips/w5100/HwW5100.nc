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

/**
 * The Wiznet5100 can be physically connected in three different ways:
 * DirectBusInterface, IndirectBusInterface, and SPI.
 * This interface abstracts away the differences between these wirings, and
 * allows the rest of the driver to simply interact with registers and
 * interrupt signals without having to worry about hardware details.
 *
 * It is up to the platform to wire up the W5100 HPL component in a
 * manner matching the actual hardware.
 */
interface HwW5100
{
  /**
   * Writes a byte to an address on the W5100 (register, tx/rx memory).
   */
  async command void out (uint16_t addr, uint8_t val);

  /**
   * Reads a byte from an address on the W5100 (register, tx/rx memory).
   */
  async command uint8_t in (uint16_t addr);

  /**
   * Fired when an interrupt request is detected from the W5100 chip.
   * Will not fire again until all bits in the IR register have been cleared.
   */
  async event void interrupt ();

  // TODO: check if we need enable/disable interrupt functions
}
