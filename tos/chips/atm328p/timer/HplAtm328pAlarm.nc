interface HplAtm328pAlarm<precision_tag, size_type>
{
  async command void start (size_type t);
  async command void stop ();
  async command bool isRunning ();
  async command size_type now ();
}
