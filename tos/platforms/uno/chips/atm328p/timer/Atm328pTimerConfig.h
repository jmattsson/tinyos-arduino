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

#ifndef __ATM328PTIMERCONFIG__
#define __ATM328PTIMERCONFIG__

#include "Atm328pTimerClockSource.h"

/* The Uno runs the internal clock at 16MHz, so prescale down to 16kHz,
 * and then do a further shift-right-by-4 transform for the milli timer. */
#define ATM328P_TIMER_0_CLOCK           TIMER_CLOCK_INTERNAL_PRESCALE_1024
#define ATM328P_TIMER_0_MILLI_DOWNSCALE 4
typedef struct {} T16khz;
#define ATM328P_TIMER_0_PRECISION_TYPE T16khz

/* The Uno runs the internal clock at 16MHz, so prescale down to 2MHz,
 * and then do a further shift-right-by-1 transform for the micro timer. */
#define ATM328P_TIMER_1_CLOCK           TIMER_CLOCK_INTERNAL_PRESCALE_8
#define ATM328P_TIMER_1_MICRO_DOWNSCALE 1
#define ATM328P_TIMER_1_32KHZ_DOWNSCALE 6
typedef struct {} T2Mhz;
#define ATM328P_TIMER_1_PRECISION_TYPE T2Mhz

#endif
