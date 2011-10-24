generic module HplAtm328pGeneralIOPinP (uint8_t port, uint8_t pin, uint8_t dir,  uint8_t bit)
{
  provides interface GeneralIO;
}
implementation
{
  async command bool GeneralIO.get ()    { return SFR_BIT_READ(port, bit); }
  async command void GeneralIO.set ()    { SFR_BIT_SET (port, bit); }
  async command void GeneralIO.clr ()    { SFR_BIT_CLR (port, bit); }
  async command void GeneralIO.toggle () { SFR_BIT_SET (pin, bit); }

  // Note: Might need to go via intermediate state (see doc8271, p79)
  // when changing pin direction under certain conditions
  async command void GeneralIO.makeInput ()  { SFR_BIT_CLR (dir, bit); }
  async command void GeneralIO.makeOutput () { SFR_BIT_SET (dir, bit); }

  async command bool GeneralIO.isInput ()  { return !SFR_BIT_READ (dir, bit); }
  async command bool GeneralIO.isOutput () { return  SFR_BIT_READ (dir, bit); }
}
