#include "Atm328pUsartConfig.h"
module PlatformUsartConfigC
{
  provides interface Atm328pUsartConfig;
}
implementation
{
  static atm328p_usart_config_t cfg = {
    mode:                 ATM328P_USART_ASYNC,
    bits:                 ATM328P_USART_BITS_8,
    parity:               ATM328P_USART_PARITY_NONE,
    two_stop_bits:        FALSE,
    polarity_rising_edge: FALSE,
    double_speed:         TRUE,
    baud:                 115200ul,
  };

  async command atm328p_usart_config_t *Atm328pUsartConfig.getConfig ()
  {
    return &cfg;
  }
}
