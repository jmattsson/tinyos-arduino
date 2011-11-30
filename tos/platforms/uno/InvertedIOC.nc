generic module InvertedIOC ()
{
  provides interface GeneralIO;
  uses interface GeneralIO as SubIO;
}
implementation
{
  // Inversion
  async command bool GeneralIO.get () { return !call SubIO.get (); }
  async command void GeneralIO.set () { call SubIO.clr (); }
  async command void GeneralIO.clr () { call SubIO.set (); }
  async command void GeneralIO.toggle () { call SubIO.toggle (); }

  // Plain call-through
  async command void GeneralIO.makeInput ()  { call SubIO.makeInput (); }
  async command void GeneralIO.makeOutput () { call SubIO.makeOutput (); }
  async command bool GeneralIO.isInput ()  { return call SubIO.isInput (); }
  async command bool GeneralIO.isOutput () { return call SubIO.isOutput (); }
}
