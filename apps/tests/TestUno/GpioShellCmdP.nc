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
module GpioShellCmdP
{
  provides
  {
    interface ShellExecute;
  }
  uses
  {
    interface ShellOutput;
    interface GeneralIO as Digital[uint8_t id];
    interface GeneralIO as Analog[uint8_t id];
  }
}
implementation
{
  const char syntax[] =
    " out <pin>\r\n"
    " in <pin>\r\n"
    " set <pin>\r\n"
    " get <pin>\r\n"
    " clr <pin>\r\n"
    " tgl <pin>\r\n"
    "<pin> = <a|d>N[N]\r\n"
  ;

  typedef struct
  {
    bool digital;
    uint8_t idx;
  } pin_t;

  // Accept "a0" -> "a5" and "d0" -> "d13", reject everything else
  bool parse_pin (const char *data, pin_t *dst)
  {
    if (data[0] == 'a')
    {
      if (data[1] >= '0' && data[1] <= '5' && !data[2])
      {
        dst->digital = FALSE;
        dst->idx = data[1] - '0';
        return TRUE;
      }
    }
    else if (data[0] == 'd')
    {
      if (data[1] >= '0' && data[1] <= '9')
      {
        uint8_t idx = data[1] - '0';
        if (data[2])
        {
          if (data[1] == '1' && data[2] >= '0' && data[2] <= '3')
          {
            idx *= 10;
            idx += data[2] - '0';
          }
          else
            return FALSE;
        }
        dst->digital = TRUE;
        dst->idx = idx;
        return TRUE;
      }
    }
    return FALSE;
  }

  error_t display_byte (uint8_t byte)
  {
    static char out[3]; // x\r\n
    out[0] = byte ? '1' : '0';
    out[1] = '\r';
    out[2] = '\n';
    return call ShellOutput.output (out, 4);
  }

  task void done ()
  {
    signal ShellExecute.executeDone (SUCCESS);
  }

  error_t make_out_pin (const pin_t *pin)
  {
    if (pin->digital)
      call Digital.makeOutput[pin->idx] ();
    else
      call Analog.makeOutput[pin->idx] ();
    post done ();
    return SUCCESS;
  }

  error_t make_in_pin (const pin_t *pin)
  {
    if (pin->digital)
      call Digital.makeInput[pin->idx] ();
    else
      call Analog.makeInput[pin->idx] ();
    post done ();
    return SUCCESS;
  }

  error_t set_pin (const pin_t *pin)
  {
    if (pin->digital)
      call Digital.set[pin->idx] ();
    else
      call Analog.set[pin->idx] ();
    post done ();
    return SUCCESS;
  }

  error_t get_pin (const pin_t *pin)
  {
    uint8_t val;
    if (pin->digital)
      val = call Digital.get[pin->idx] ();
    else
      val = call Analog.get[pin->idx] ();
    return display_byte (val);
  }

  error_t clr_pin (const pin_t *pin)
  {
    if (pin->digital)
      call Digital.clr[pin->idx] ();
    else
      call Analog.clr[pin->idx] ();
    post done ();
    return SUCCESS;
  }

  error_t tgl_pin (const pin_t *pin)
  {
    if (pin->digital)
      call Digital.toggle[pin->idx] ();
    else
      call Analog.toggle[pin->idx] ();
    post done ();
    return SUCCESS;
  }


  command error_t ShellExecute.execute (uint8_t argc, const char *argv[])
  {
    pin_t pin;

    if (argc == 1)
      return call ShellOutput.output (syntax, sizeof (syntax) -1);

    if (argc != 3)
      return EINVAL;

    if (!parse_pin (argv[2], &pin))
      return EINVAL;

    if (strcmp (argv[1], "out") == 0)
      return make_out_pin (&pin);
    else if (strcmp (argv[1], "in") == 0)
      return make_in_pin (&pin);
    else if (strcmp (argv[1], "set") == 0)
      return set_pin (&pin);
    else if (strcmp (argv[1], "get") == 0)
      return get_pin (&pin);
    else if (strcmp (argv[1], "clr") == 0)
      return clr_pin (&pin);
    else if (strcmp (argv[1], "tgl") == 0)
      return tgl_pin (&pin);
    else
      return FAIL;
  }

  command void ShellExecute.abort () {}


  event void ShellOutput.outputDone ()
  {
    signal ShellExecute.executeDone (SUCCESS);
  }

  async default command void Digital.makeOutput[uint8_t x] () {}
  async default command void Analog.makeOutput[uint8_t x] () {}
  async default command void Digital.makeInput[uint8_t x] () {}
  async default command void Analog.makeInput[uint8_t x] () {}
  async default command void Digital.set[uint8_t x] () {}
  async default command void Analog.set[uint8_t x] () {}
  async default command void Digital.clr[uint8_t x] () {}
  async default command void Analog.clr[uint8_t x] () {}
  async default command void Digital.toggle[uint8_t x] () {}
  async default command void Analog.toggle[uint8_t x] () {}
  async default command uint8_t Digital.get[uint8_t x] () { return 0; }
  async default command uint8_t Analog.get[uint8_t x] () { return 0; }
}
