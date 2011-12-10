configuration HilTimerMilliC
{
  provides interface Init;
  provides interface Timer<TMilli> as TimerMilli[uint8_t num];
  provides interface LocalTime<TMilli>;
}
implementation
{
  components new AlarmMilli32C(), CounterMilli32C, NoInitC;

  Init = NoInitC;

  components new AlarmToTimerC (TMilli) as TimerC;
  TimerC.Alarm -> AlarmMilli32C;

  components new VirtualizeTimerC (TMilli, uniqueCount(UQ_TIMER_MILLI))
    as VirtualTimerC;
  VirtualTimerC.TimerFrom -> TimerC;

  TimerMilli = VirtualTimerC;

  components new CounterToLocalTimeC (TMilli) as LocalTimeC;
  LocalTimeC.Counter -> CounterMilli32C;

  LocalTime = LocalTimeC;

}
