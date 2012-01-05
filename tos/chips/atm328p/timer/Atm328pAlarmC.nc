generic module Atm328pAlarmC(typedef precision_tag, typedef size_type @integer(), uint16_t MIN_DELTA_T)
{
  provides interface Alarm<precision_tag, size_type>;
  uses interface HplAtm328pAlarm<precision_tag, size_type> as HplAlarm;
  uses interface HplAtm328pAlarmIsr as Isr;
}
implementation
{
  size_type m_alarmAt;

  async event void Isr.fired ()
  {
    call HplAlarm.stop ();
    signal Alarm.fired ();
  }

  async command void Alarm.start (size_type dt)
  {
    atomic call Alarm.startAt (call Alarm.getNow (), dt);
  }

  async command void Alarm.stop ()
  {
    call HplAlarm.stop ();
  }

  async command bool Alarm.isRunning ()
  {
    return call HplAlarm.isRunning ();
  }

  async command void Alarm.startAt (size_type t0, size_type dt)
  {
    atomic {
      size_type now;
      size_type next = t0 + dt;

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
       * appropriate value for MIN_DELTA_T should be for the particular
       * instance.
       */
      m_alarmAt = call Alarm.getNow () + dt + 1 + MIN_DELTA_T;

      call HplAlarm.start (m_alarmAt);
    }
  }

  async command size_type Alarm.getNow ()
  {
    atomic return call HplAlarm.now ();
  }

  async command size_type Alarm.getAlarm ()
  {
    atomic return m_alarmAt;
  }

  default async event void Alarm.fired () {}
}
