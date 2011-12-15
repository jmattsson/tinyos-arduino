#ifndef _ATM328PUSARTCONFIG_H_
#define _ATM328PUSARTCONFIG_H_

typedef enum {
  ATM328P_USART_ASYNC    = 0x00,
  ATM328P_USART_SYNC     = 0x01,
  ATM328P_USART_MSPI     = 0x03,
} atm328p_usart_mode_t;

typedef enum {
  ATM328P_USART_BITS_5  = 0x00,
  ATM328P_USART_BITS_6  = 0x01,
  ATM328P_USART_BITS_7  = 0x02,
  ATM328P_USART_BITS_8  = 0x03,
  ATM328P_USART_BITS_9  = 0x07,
} atm328p_usart_bits_t;

typedef enum
{
  ATM328P_USART_PARITY_NONE = 0x00,
  ATM328P_USART_PARITY_EVEN = 0x02,
  ATM328P_USART_PARITY_ODD  = 0x03,
} atm328p_usart_parity_t;

typedef struct
{
  atm328p_usart_mode_t mode;
  atm328p_usart_bits_t bits;
  atm328p_usart_parity_t parity;
  bool two_stop_bits;
  bool polarity_rising_edge;
  bool double_speed;
  uint32_t baud;
} atm328p_usart_config_t;

#endif
