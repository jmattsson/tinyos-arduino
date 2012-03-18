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

generic module HplAtm328pGeneralIOPinP (uint8_t port, uint8_t pin, uint8_t dir,  uint8_t bit)
{
  provides interface GeneralIO;
}
implementation
{
  async command bool GeneralIO.get ()
  {
    return SFR_BIT_SET (_SFR_MEM8 (port), bit);
  }

  async command void GeneralIO.set ()
  {
    SFR_SET_BIT ( _SFR_MEM8(port), bit);
  }

  async command void GeneralIO.clr ()
  {
    SFR_CLR_BIT ( _SFR_MEM8(port), bit);
  }

  async command void GeneralIO.toggle ()
  {
    SFR_SET_BIT (_SFR_MEM8(pin), bit);
  }

  // Note: Might need to go via intermediate state (see doc8271, p79)
  // when changing pin direction under certain conditions
  async command void GeneralIO.makeInput ()
  {
    SFR_CLR_BIT (_SFR_MEM8(dir), bit);
  }

  async command void GeneralIO.makeOutput ()
  {
    SFR_SET_BIT (_SFR_MEM8(dir), bit);
  }

  async command bool GeneralIO.isInput ()
  {
    return SFR_BIT_CLR (_SFR_MEM8(dir), bit);
  }

  async command bool GeneralIO.isOutput ()
  {
    return SFR_BIT_SET (_SFR_MEM8(dir), bit);
  }
}
