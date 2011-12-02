generic module HplAtm328pAlarmC(typedef precision_tag, typedef size_type @integer(), uint8_t OCREG, uint8_t CNTREG, uint8_t TIMSKREG, uint8_t TIMSK_BIT, uint8_t TIFREG, uint8_t TIFREG_BIT, uint16_t MIN_DELAY)
{
  provides interface Alarm<precision_tag, size_type>;
  uses interface HplAtm328pAlarmIsr as Isr;
}
implementation
{
  size_type m_t0;

  async event void Isr.fired ()
  {
    signal Alarm.fired ();
  }

  async command void Alarm.start (size_type dt)
  {
    atomic {
      m_t0 = call Alarm.getNow ();
      call Alarm.startAt (m_t0, dt);
    }
  }

  async command void Alarm.stop ()
  {
    *(uint8_t *)TIMSKREG &= ~TIMSK_BIT; /* disable compare interrupt */
  }

  async command bool Alarm.isRunning ()
  {
    return SFR_BIT_READ(TIMSKREG, TIMSK_BIT);
  }

  async command void Alarm.startAt (size_type t0, size_type dt)
  {
    atomic {
      size_type now;
      size_type next = t0 + dt;

      *(uint8_t *)TIFREG |= TIFREG_BIT; /* clear compare interrupt flag */

      now = call Alarm.getNow ();

      /* t0 is always assumed to be in the past */
      if (t0 > now)
      {
        if ((next >= t0) || (next <= now))
        {
          dt = 0;
          goto doit; /* wanted alarm some time in the past */
        }
      }
      else
      {
        if ((next >= t0) && (next <= now))
        {
          dt = 0;
          goto doit; /* wanted alarm some time in the past */
        }
      }

      /* make the delta-t relative to current counter time */
      dt = next - now;

    doit:
      /* It's not possible to match on the very next counter value, so need
       * to bump by at least one. For high-frequency counters, we might also
       * need to add a few extra cycles to avoid missing the match while doing
       * these calculations. Check the assembler output to work out what the
       * appropriate value for MIN_DELAY should be for the particular instance.
       */
      dt += call Alarm.getNow () + 1 + MIN_DELAY;

      *(size_type *)OCREG = dt;
      *(uint8_t *)TIMSKREG |= TIMSK_BIT; /* enable compare interrupt */
    }
  }

  async command size_type Alarm.getNow ()
  {
    atomic return CNTREG;
  }

  async command size_type Alarm.getAlarm ()
  {
    atomic return m_t0;
  }
}
