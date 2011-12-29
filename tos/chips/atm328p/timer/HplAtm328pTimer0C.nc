#include <Atm328pTimerConfig.h>
configuration HplAtm328pTimer0C
{
  provides interface HplAtm328pTimer<uint8_t>;
}
implementation
{
  components HplAtm328pTimer0P, RealMainP;
  HplAtm328pTimer0P.PlatformInit <- RealMainP.PlatformInit;
  HplAtm328pTimer = HplAtm328pTimer0P;
}
