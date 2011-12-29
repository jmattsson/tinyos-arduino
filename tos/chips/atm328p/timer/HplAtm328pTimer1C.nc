#include <Atm328pTimerConfig.h>
configuration HplAtm328pTimer1C
{
  provides interface HplAtm328pTimer<uint16_t>;
}
implementation
{
  components HplAtm328pTimer1P, RealMainP;
  HplAtm328pTimer1P.PlatformInit <- RealMainP.PlatformInit;
  HplAtm328pTimer = HplAtm328pTimer1P;
}
