module PlatformUsartConfigC
{
  provides interface Atm328pUsartConfig;
}
implementation
{
  static struct atm328p_usart_config_t cfg = {
    .mode   = ATM328P_USART_ASYNC,
    .bits   = ATM328P_USART_BITS_8,
    .parity = ATM328P_USART_PARITY_NONE,
    .two_stop_bits = FALSE,
    .polarity_rising_edge = FALSE,
    .double_speed = FALSE,
    .baud = 115200,
  };

  command atm328p_usart_config_t *Atm328pUsartConfig.getConfig ()
  {
    return &cfg;
  }
}
