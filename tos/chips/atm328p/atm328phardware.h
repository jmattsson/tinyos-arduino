#ifndef _ATM328PHARDWARE_H_
#define _ATM328PHARDWARE_H_

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

#define AVR_ATOMIC_HANDLER(signame) \
    void signame () __attribute__((signal)) @atomic_hwevent() @C()

#define AVR_NONATOMIC_HANDLER(signame) \
    void signame () __attribute__((interrupt)) @hwevent() @C()

#define SFR_BIT_SET(reg, bit) \
    asm ("sbi %0, %1" : : "I" (reg - __SFR_OFFSET), "I" (bit) )

#define SFR_BIT_CLR(reg, bit) \
    asm ("cbi %0, %1" : : "I" (reg - __SFR_OFFSET), "I" (bit) )

#define SFR_BIT_READ(reg, bit) \
    ((*((uint8_t *)(reg - __SFR_OFFSET)) & _BV(bit)) != 0)

typedef struct {} T64khz;
#define UQ_TIMER_0_ALARM "atm328p.timer0.alarm"
#define UQ_TIMER_1_ALARM "atm328p.timer1.alarm"

#endif
