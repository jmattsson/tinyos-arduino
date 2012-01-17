/*
 * Copyright (c) 2012 Johny Mattsson
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "Atm328pAdc.h"
#include <stdlib.h>

module AdcShellCmdP
{
  provides
  {
    interface ShellExecute;
    interface AdcConfigure<const Atm328pAdcConfig_t *>;
  }
  uses
  {
    interface ShellOutput;
    interface Read<uint16_t>;
    interface ReadStream<uint16_t>;
    interface VariantPool as Scratch;
  }
}
implementation
{
  enum { LINE_LEN = 7 }; // 5 digits, crlf

  enum { ADC_CMD_NONE, ADC_CMD_READ, ADC_CMD_STREAM } op = ADC_CMD_NONE;

  const char syntax[] =
    " adc conf prescale <2,4,8,16,32,64,128>\r\n"
    " adc conf chan <0-7,temp,vref,gnd>\r\n"
    " adc stream <period (us)> <count>\r\n"
    " adc read\r\n"
    " adc show\r\n";

  char *buf = 0;

  bool done = FALSE;
  error_t done_result = SUCCESS;

  Atm328pAdcConfig_t cfg = {
    .reference = ATM328P_ADC_REF_INTERNAL,
    .prescale  = ATM328P_ADC_PRESCALE_128,
    .channel   = ATM328P_ADC_CHANNEL_TEMP,
    .digital_input = FALSE,
  };

  struct {
    error_t code;
    uint32_t period;
  } stream_result;


  task void do_show_adc ()
  {
    char *p;
    size_t len, l;
    const char *tmp;
    error_t result = ENOMEM;

    p = buf = call Scratch.reserve (&len);
    if (!buf)
      goto err_mem;

    switch (cfg.prescale)
    {
      case ATM328P_ADC_PRESCALE_2:   tmp =   "2"; break;
      case ATM328P_ADC_PRESCALE_4:   tmp =   "4"; break;
      case ATM328P_ADC_PRESCALE_8:   tmp =   "8"; break;
      case ATM328P_ADC_PRESCALE_16:  tmp =  "16"; break;
      case ATM328P_ADC_PRESCALE_32:  tmp =  "32"; break;
      case ATM328P_ADC_PRESCALE_64:  tmp =  "64"; break;
      case ATM328P_ADC_PRESCALE_128: tmp = "128"; break;
      default: tmp = "?"; break;
    }
    l = snprintf (p, len - (p - buf), " prescale: %s\r\n", tmp);
    if (l >= len)
      goto err_mem;

    p += l;

    switch (cfg.channel)
    {
      case ATM328P_ADC_CHANNEL_0:    tmp =    "0"; break;
      case ATM328P_ADC_CHANNEL_1:    tmp =    "1"; break;
      case ATM328P_ADC_CHANNEL_2:    tmp =    "2"; break;
      case ATM328P_ADC_CHANNEL_3:    tmp =    "3"; break;
      case ATM328P_ADC_CHANNEL_4:    tmp =    "4"; break;
      case ATM328P_ADC_CHANNEL_5:    tmp =    "5"; break;
      case ATM328P_ADC_CHANNEL_6:    tmp =    "6"; break;
      case ATM328P_ADC_CHANNEL_7:    tmp =    "7"; break;
      case ATM328P_ADC_CHANNEL_TEMP: tmp = "temp"; break;
      case ATM328P_ADC_CHANNEL_VREF: tmp = "vref"; break;
      case ATM328P_ADC_CHANNEL_GND:  tmp =  "gnd"; break;
      default: tmp = "?"; break;
    }
    l = snprintf (p, len - (p - buf), " channel: %s\r\n", tmp);
    if (l >= len)
      goto err_mem;

    p += l;
    len = p - buf;
    call Scratch.reduce (buf, len);

    result = call ShellOutput.output (buf, len);
    if (result == SUCCESS)
    {
      done_result = SUCCESS;
      done = TRUE;
      return;
    }

  err_mem:
    call Scratch.release (buf);
    buf = 0;
    signal ShellExecute.executeDone (result);
  }

  task void conf_adc_done ()
  {
    signal ShellExecute.executeDone (SUCCESS);
  }

  error_t conf_adc (const char *what, const char *val)
  {
    if (strcmp (what, "prescale") == 0)
    {
      switch (atoi (val))
      {
        case   2: cfg.prescale = ATM328P_ADC_PRESCALE_2;   break;
        case   4: cfg.prescale = ATM328P_ADC_PRESCALE_4;   break;
        case   8: cfg.prescale = ATM328P_ADC_PRESCALE_8;   break;
        case  16: cfg.prescale = ATM328P_ADC_PRESCALE_16;  break;
        case  32: cfg.prescale = ATM328P_ADC_PRESCALE_32;  break;
        case  64: cfg.prescale = ATM328P_ADC_PRESCALE_64;  break;
        case 128: cfg.prescale = ATM328P_ADC_PRESCALE_128; break;
        default: return FAIL;
      }
      post conf_adc_done ();
      return SUCCESS;
    }
    else if (strcmp (what, "chan") == 0)
    {
      if (strcmp (val, "temp") == 0)
        cfg.channel = ATM328P_ADC_CHANNEL_TEMP;
      else if (strcmp (val, "vref") == 0)
        cfg.channel = ATM328P_ADC_CHANNEL_VREF;
      else if (strcmp (val, "gnd") == 0)
        cfg.channel = ATM328P_ADC_CHANNEL_GND;
      else switch (atoi (val))
      {
        case 0: cfg.channel = ATM328P_ADC_CHANNEL_0; break;
        case 1: cfg.channel = ATM328P_ADC_CHANNEL_1; break;
        case 2: cfg.channel = ATM328P_ADC_CHANNEL_2; break;
        case 3: cfg.channel = ATM328P_ADC_CHANNEL_3; break;
        case 4: cfg.channel = ATM328P_ADC_CHANNEL_4; break;
        case 5: cfg.channel = ATM328P_ADC_CHANNEL_5; break;
        case 6: cfg.channel = ATM328P_ADC_CHANNEL_6; break;
        case 7: cfg.channel = ATM328P_ADC_CHANNEL_7; break;
        default: return FAIL;
      }
      post conf_adc_done ();
      return SUCCESS;
    }
    return FAIL;
  }

  error_t read_adc ()
  {
    op = ADC_CMD_READ;
    return call Read.read ();
  }

  error_t stream_adc (uint16_t usPeriod, int count)
  {
    error_t result;
    uint16_t *arr;

    if (count > 100)
      return ENOMEM;

    arr = malloc (count * sizeof (uint16_t));
    if (!arr)
      return ENOMEM;

    result = call ReadStream.postBuffer (arr, count);
    if (result != SUCCESS)
    {
      free (arr);
      return result;
    }

    op = ADC_CMD_STREAM;

    return call ReadStream.read (usPeriod);
  }

  task void do_cancel ()
  {
    op = ADC_CMD_NONE;
    call Scratch.release (buf); // might cause garbage output if unlucky...
    buf = 0;
    signal ShellExecute.executeDone (ECANCEL);
  }

  task void do_stream_done ()
  {
    size_t len;

    // If the scratch buffer is still in use, we likely can't output anything,
    // so repost ourselves to try again.
    if (buf)
    {
      post do_stream_done ();
      return;
    }

    op = ADC_CMD_NONE;

    buf = call Scratch.reserve (&len);
    if (!buf)
      goto err_out;
    else
    {
      size_t l = snprintf (
        buf, len, "Actual period: %luus\r\n", stream_result.period);
      if (l >= len)
        goto err_out;
      if (call ShellOutput.output (buf, l) != SUCCESS)
        goto err_out;

      done_result = stream_result.code;
      done = TRUE;
    }
    return;

  err_out:
    call Scratch.release (buf);
    buf = 0;
    signal ShellExecute.executeDone (ENOMEM);
  }


  async command const Atm328pAdcConfig_t *AdcConfigure.getConfiguration ()
  {
    atomic return &cfg;
  }


  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    if (op != ADC_CMD_NONE || buf)
      return EBUSY;

    if (argc == 1)
    {
      call ShellOutput.output (syntax, sizeof (syntax) -1);
      return FAIL;
    }

    if (strcmp (argv[1], "conf") == 0 && argc == 4)
      return conf_adc (argv[2], argv[3]);
    else if (strcmp (argv[1], "read") == 0 && argc == 2)
      return read_adc ();
    else if (strcmp (argv[1], "stream") == 0 && argc == 4)
      return stream_adc (atoi (argv[2]), atoi (argv[3]));
    else if (strcmp (argv[1], "show") == 0 && argc == 2)
    {
      post do_show_adc ();
      return SUCCESS;
    }
    else
      return FAIL;
  }

  command void ShellExecute.abort ()
  {
    post do_cancel ();
  }


  event void ShellOutput.outputDone ()
  {
    call Scratch.release (buf);
    buf = 0;

    if (done)
    {
      done = FALSE;
      signal ShellExecute.executeDone (done_result);
    }
  }


  event void Read.readDone (error_t result, uint16_t val)
  {
    if (op != ADC_CMD_READ)
      return; // not for us

    op = ADC_CMD_NONE;

    if (result != SUCCESS)
    {
      signal ShellExecute.executeDone (result);
      return;
    }

    buf = call Scratch.alloc (LINE_LEN + 1); // 5 digits, crlf, \0
    if (!buf)
    {
      signal ShellExecute.executeDone (ENOMEM);
      return;
    }

    sprintf (buf, "%u\r\n", val);
    result = call ShellOutput.output (buf, strlen (buf));
    if (result != SUCCESS)
      signal ShellExecute.executeDone (result);

    done_result = SUCCESS;
    done = TRUE;
  }

  event void ReadStream.bufferDone (error_t result, uint16_t *arr, uint16_t n)
  {
    char *p;
    uint16_t i;

    if (op != ADC_CMD_STREAM)
      return; // not for us

    if (result != SUCCESS)
    {
      signal ShellExecute.executeDone (result);
      return;
    }

    buf = call Scratch.alloc (n * LINE_LEN + 1);
    if (!buf)
    {
      signal ShellExecute.executeDone (ENOMEM);
      return;
    }

    for (p = buf, i = 0; i < n; ++i)
      p += sprintf (p, "%u\r\n", arr[i]);

    i = p - buf;
    call Scratch.reduce (buf, i);

    free (arr);

    if (call ShellOutput.output (buf, i) != SUCCESS)
    {
      call Scratch.release (buf);
      buf = 0;
    }
  }

  event void ReadStream.readDone (error_t result, uint32_t usPeriod)
  {
    stream_result.code = result;
    stream_result.period = usPeriod;
    post do_stream_done ();
  }
}
