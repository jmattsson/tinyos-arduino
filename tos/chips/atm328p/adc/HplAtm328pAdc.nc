interface HplAtm328pAdc
{
  async command void setReference (Atm328pAdcRef_t ref);
  async command Atm328pAdcRef_t getReference ();

  async command void setChannel (Atm328pAdcChannel_t channel);
  async command Atm328pAdcChannel_t getChannel ();

  async command void startConversion ();
  async command bool isConverting ();

  async command void enableAutoTrigger ();
  async command void disableAutoTrigger ();
  async command bool isAutoTriggered ();
  async command void setAutoTriggerSource (Atm328pAdcTriggerSource_t source);
  async command Atm328pAdcTriggerSource_t getAutoTriggerSource ();

  async command void enableInterrupt ();
  async command void disableInterrupt ();
  async command bool interruptEnabled ();
  async event void done ();

  async command void setPrescaler (Atm328pPrescale_t prescale);
  async command Atm328pPrescale_t getPrescaler ();

  async command void enableDigitalInput (Atm328pChannel_t channel);
  async command void disableDigitalInput (Atm328pChannel_t channel);
  async command bool digitalInputEnabled (Atm328pChannel_t channel);

  async command uint16_t get ();
}
