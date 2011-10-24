#ifndef _ATM328PHARDWARE_H_
#define _ATM328PHARDWARE_H_

#define __SFR_OFFSET 0x00
#include <avr/io.h>
#include <avr/interrupt.h>

typedef uint8_t __nesc_atomic_t;

inline void __nesc_enable_interrupt() {
     sei ();
}

inline void __nesc_disable_interrupt() {
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

#define SFR_BIT_SET(reg, bit) \
    asm ("sbi %0, %1" : : "I" (reg), "I" (bit) )

#define SFR_BIT_CLR(reg, bit) \
    asm ("cbi %0, %1" : : "I" (reg), "I" (bit) )

#define SFR_BIT_READ(reg, bit) \
    ((*((uint8_t *)reg) & _BV(bit)) != 0)

#endif
