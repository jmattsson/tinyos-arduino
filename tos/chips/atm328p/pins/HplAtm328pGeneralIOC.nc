#include <atm328phardware.h>

configuration HplAtm328pGeneralIOC
{
  provides
  {
    interface GeneralIO as PortB0;
    interface GeneralIO as PortB1;
    interface GeneralIO as PortB2;
    interface GeneralIO as PortB3;
    interface GeneralIO as PortB4;
    interface GeneralIO as PortB5;
    interface GeneralIO as PortB6;
    interface GeneralIO as PortB7;

    interface GeneralIO as PortC0;
    interface GeneralIO as PortC1;
    interface GeneralIO as PortC2;
    interface GeneralIO as PortC3;
    interface GeneralIO as PortC4;
    interface GeneralIO as PortC5;
    interface GeneralIO as PortC6;
    interface GeneralIO as PortC7;

    interface GeneralIO as PortD0;
    interface GeneralIO as PortD1;
    interface GeneralIO as PortD2;
    interface GeneralIO as PortD3;
    interface GeneralIO as PortD4;
    interface GeneralIO as PortD5;
    interface GeneralIO as PortD6;
    interface GeneralIO as PortD7;
  }
}
implementation
{
  components
    new HplAtm328pGeneralIOPortP ((uint8_t)&PORTB, (uint8_t)&PINB, (uint8_t)&DDRB) as PortB,
    new HplAtm328pGeneralIOPortP ((uint8_t)&PORTC, (uint8_t)&PINC, (uint8_t)&DDRC) as PortC,
    new HplAtm328pGeneralIOPortP ((uint8_t)&PORTD, (uint8_t)&PIND, (uint8_t)&DDRD) as PortD;

  PortB0 = PortB.Pin0;
  PortB1 = PortB.Pin1;
  PortB2 = PortB.Pin2;
  PortB3 = PortB.Pin3;
  PortB4 = PortB.Pin4;
  PortB5 = PortB.Pin5;
  PortB6 = PortB.Pin6;
  PortB7 = PortB.Pin7;

  PortC0 = PortC.Pin0;
  PortC1 = PortC.Pin1;
  PortC2 = PortC.Pin2;
  PortC3 = PortC.Pin3;
  PortC4 = PortC.Pin4;
  PortC5 = PortC.Pin5;
  PortC6 = PortC.Pin6;
  PortC7 = PortC.Pin7;

  PortD0 = PortD.Pin0;
  PortD1 = PortD.Pin1;
  PortD2 = PortD.Pin2;
  PortD3 = PortD.Pin3;
  PortD4 = PortD.Pin4;
  PortD5 = PortD.Pin5;
  PortD6 = PortD.Pin6;
  PortD7 = PortD.Pin7;
}

