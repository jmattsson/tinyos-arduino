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

configuration Atm328pSpiC
{
  provides
  {
    interface SpiByte;
    interface SpiPacket;
    interface FastSpiByte;
    interface Resource[uint8_t id];
  }
}
implementation
{
  components Atm328pSpiP, HplAtm328pSpiC, HplAtm328pPowerC,
    new SimpleArbiterP() as ArbiterP,
    new FcfsResourceQueueC(uniqueCount(UQ_SPI)) as QueueC;

  ArbiterP.Queue -> QueueC;

  Atm328pSpiP.SpiControl -> HplAtm328pSpiC;
  Atm328pSpiP.HplSpi     -> HplAtm328pSpiC;
  Atm328pSpiP.HplPower   -> HplAtm328pPowerC;
  Atm328pSpiP.Arbiter    -> ArbiterP;

  components HplAtm328pGeneralIOC as IO;
  Atm328pSpiP.SS   -> IO.PortB2;
  Atm328pSpiP.SCK  -> IO.PortB5;
  Atm328pSpiP.MOSI -> IO.PortB3;
  Atm328pSpiP.MISO -> IO.PortB4;

  components McuInitP;
  McuInitP.IoBusInit -> Atm328pSpiP;
  McuInitP.IoBusInit -> QueueC;

  SpiByte     = Atm328pSpiP;
  SpiPacket   = Atm328pSpiP;
  FastSpiByte = Atm328pSpiP;
  Resource    = Atm328pSpiP;
}
