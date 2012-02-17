#ifndef _ATM328P_SPI_H_
#define _ATM328P_SPI_H_

// Note: the SPI clock divisors are halved if double-speed is enabled
typedef enum
{
  ATM328P_SPI_CLOCK_DIV_4   = 0,
  ATM328P_SPI_CLOCK_DIV_16  = 1,
  ATM328P_SPI_CLOCK_DIV_64  = 2,
  ATM328P_SPI_CLOCK_DIV_128 = 3,
} atm328p_spi_clock_div_t;

#define UQ_SPI "atm328p.spi"

#endif
