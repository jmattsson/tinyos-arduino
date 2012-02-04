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
#ifndef _H_atm328phardware_h
#define _H_atm328phardware_h

#include <avr/io.h>
#include <avr/interrupt.h>

typedef uint8_t __nesc_atomic_t;

inline void __nesc_enable_interrupt()
{
    sei ();
}

inline void __nesc_disable_interrupt()
{
    cli ();
}


inline __nesc_atomic_t __nesc_atomic_start ()
{
    __nesc_atomic_t result = SREG;
    __nesc_disable_interrupt ();
    asm volatile ("" : : : "memory");
    return result;
}

inline void __nesc_atomic_end (__nesc_atomic_t old_SREG)
{
    SREG = old_SREG;
    asm volatile ("" : : : "memory");
}

#define AVR_ATOMIC_HANDLER(signame) \
    void signame () __attribute__((signal)) @atomic_hwevent() @C()

/* Hmm, the atm328p doesn't have support for interrupt priorities, so allowing
 * nested interrupts would open up the potential for very easy stack overflows.
 * For now, it seems best not to support the notion of nested interrupts.
 *
#define AVR_NONATOMIC_HANDLER(signame) \
    void signame () __attribute__((interrupt)) @hwevent() @C()
 */


typedef enum {
  ATM328P_POWER_IDLE,
  ATM328P_POWER_ADC_NOISERED,
  ATM328P_POWER_EXT_STANDBY,
  ATM328P_POWER_SAVE,
  ATM328P_POWER_STANDBY,
  ATM328P_POWER_DOWN
} __attribute__((packed)) mcu_power_t @combine("combine_mcu_power_t");

inline mcu_power_t combine_mcu_power_t (mcu_power_t mp1, mcu_power_t mp2)
{
  return (mp1 < mp2) ? mp1 : mp2;
}


// Adjust register accesses to allow the compiler to use short instructions
// (cbi/sbi/in/out) rather than the standard load/store ops (lds/sts).
// By default register accesses use the memory-mapped version of the register.
#define OPTIMAL_ACCESS(reg) \
  _MMIO_BYTE(_SFR_IO_REG_P(reg) ? _SFR_IO_ADDR(reg) : _SFR_MEM_ADDR(reg))

// Write
#define SFR_SET_BIT(reg, bit)  OPTIMAL_ACCESS(reg) |= _BV(bit)
#define SFR_CLR_BIT(reg, bit)  OPTIMAL_ACCESS(reg) &= ~_BV(bit)

// Read
#define SFR_BIT_SET(reg, bit) ((OPTIMAL_ACCESS(reg) & _BV(bit)))
#define SFR_BIT_CLR(reg, bit) (!SFR_BIT_SET(reg,bit))

#define UQ_TIMER_0_ALARM "atm328p.timer0.alarm"
#define UQ_TIMER_1_ALARM "atm328p.timer1.alarm"

#endif
