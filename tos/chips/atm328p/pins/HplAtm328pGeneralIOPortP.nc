generic configuration HplAtm328pGeneralIOPortP (uint8_t port, uint8_t pin, uint8_t dir)
{
  provides
  {
    interface GeneralIO as Pin0;
    interface GeneralIO as Pin1;
    interface GeneralIO as Pin2;
    interface GeneralIO as Pin3;
    interface GeneralIO as Pin4;
    interface GeneralIO as Pin5;
    interface GeneralIO as Pin6;
    interface GeneralIO as Pin7;
  }
}
implementation
{
  components
    new HplAtm328pGeneralIOPinP (port, pin, dir, 0) as IOPin0,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 1) as IOPin1,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 2) as IOPin2,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 3) as IOPin3,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 4) as IOPin4,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 5) as IOPin5,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 6) as IOPin6,
    new HplAtm328pGeneralIOPinP (port, pin, dir, 7) as IOPin7;

  Pin0 = IOPin0;
  Pin1 = IOPin1;
  Pin2 = IOPin2;
  Pin3 = IOPin3;
  Pin4 = IOPin4;
  Pin5 = IOPin5;
  Pin6 = IOPin6;
  Pin7 = IOPin7;
}
