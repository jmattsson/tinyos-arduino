module AdcP
{
  provides
  {
    interface Read<uint16_t>[uint8_t id];
    interface ReadNow<uint16_t>[uint8_t id];
    interface ReadStream<uint16_t>[uint8_t id];
  }

  uses
  {
    interface AdcConfigure<const Atm328pAdcConfig_t *>[uint8_t id];
    interface Resource[uint8_t id];
    interface HplAtm328pAdc as Adc;
  }
}
implementation
{
  typedef enum {
    ATM328P_ADC_NONE,
    ATM328P_ADC_READ,
    ATM328P_ADC_READNOW,
    ATM328P_ADC_READSTREAM
  } op_mode_t;

  op_mode_t op;
  uint8_t client;
  uint16_t *spare = 0; // list of spare buffers
  uint16_t *buffer = 0, uint16_t buffer_count = 0, buffer_used = 0;
  uint16_t *done_buffer = 0, done_count = 0;
  uint32_t usActualPeriod;

  bool read_stream_done_pending;
  bool read_stream_failed;


  void apply_configuration (const Atm328pAdcConfig_t *cfg)
  {
    call Adc.disableAutoTrigger ();
    call Adc.setReference (cfg->reference);
    call Adc.setPrescaler (cfg->prescale);
    call Adc.setChannel (cfg->channel);
    if (cfg->digital_input)
      call Adc.enableDigitalInput (cfg->channel);
    else
      call Adc.disableDigitalInput (cfg->channel);
    call Adc.enableInterrupt ();
  }

  uint16_t *next_buffer (uint8_t id)
  {
    uint16_t **next = &spare;
    while (*next)
    {
      uint16_t *buf = *next;
      if (buf[2] == id)
      {
        *next = (uint16_t *)buf[0];
        return buf;
      }
      else
        next = &(uint16_t *)buf[0];
    }
    return 0;
  }


  command error_t Read.read[uint8_t id] ()
  {
    atomic {
      if (op != ATM328P_ADC_NONE || call Adc.isConverting ())
        return EBUSY;

      op = ATM328P_ADC_READ;
    }

    apply_configuration (call AdcConfigure[id].getConfiguration ());
    client = id;
    call Adc.startConversion ();

    return SUCCESS;
  }


  async command error_t ReadNow.read[uint8_t id] ()
  {
    atomic {
      if (!call Resource[id].isOwner ())
        return FAIL;
      if (op != ATM328P_ADC_NONE || call Adc.isConverting ())
        return EBUSY;

      op = ATM328P_ADC_READNOW;
    }

    apply_configuration (call AdcConfigure[id].getConfiguration ());
    client = id;
    call Adc.startConversion ();

    return SUCCESS;
  }


  command error_t ReadStream.postBuffer[uint8_t id] (uint16_t *buf, uint16_t count)
  {
    /* TEP114 reserves enough space in a buffer to allow using it in a linked
     * list, but doesn't take the client id into account. Given the
     * implementation of ArbitratedReadStreamC, we need to store the client id
     * together with the buffer so we don't end up using another client's
     * buffer (race between two clients calling .read() after posting their
     * individual buffers). The other approach would be to have per-client
     * buffer queues, but that seems unnecessarily wasteful. Better to be
     * slightly more stringent on what buffers can be used.
     */
    if (count < 3) // next *, count, id
      return FAIL;

    atomic {
      if (read_stream_done_pending)
        return FAIL;
    }

    buf[1] = count;
    buf[2] = id;
    atomic {
      buf[0] = (uint16_t)spare;
      spare = buf;
    }
    return SUCCESS;
  }

  command error_t ReadStream.read[uint8_t id) (uint32_t usPeriod)
  {
    atomic {
      if (op != ATM328P_ADC_NONE)
        return EBUSY;
      if (!spare)
        return ENOMEM;

      op = ATM328P_ADC_READSTREAM;

      read_stream_done_pending = FALSE;
      read_stream_failed = FALSE;
    }

    apply_configuration (call AdcConfigure[id].getConfiguration ());
    client = id;
    // FIXME - set up timer compare
    call Adc.setAutoTriggerSource (ATM328P_ADC_TRIGGER_TIMER1_COMP_B);
    call Adc.enableAutoTrigger ();

    return SUCCESS;
  }


  task void adc_task ()
  {
    op_mode_t mode;
    uint8_t id = client;

    atomic mode = op;

    switch (mode)
    {
      case ATM328P_ADC_READ:
      {
        uint16_t val = call Adc.get ();
        atomic op = ATM328P_ADC_NONE;
        signal Read[id].readDone (SUCCESS, val);
        break;
      }
      case ATM328P_ADC_READSTREAM:
      {
        uint16_t *buf = 0, count;
        bool failed, done;
        atomic {
          failed = read_stream_failed;
          done = read_stream_done_pending;
          if (done_buffer)
          {
            buf = done_buffer;
            count = done_count;
            done_buffer = 0;
          }
        }
        if (buf)
          signal ReadStream.bufferDone (SUCCESS, buf, count);

        if (failed)
        {
          signal ReadStream.bufferDone (FAIL, buffer, buffer_used);
          while ((buf = next_buffer (id)))
            signal ReadStream.bufferDone (FAIL, buf, 0);
        }

        if (done)
        {
          atomic {
            read_stream_pending_done = FALSE;
            buffer = 0;
            buffer_used = buffer_count = 0;
            op = ATM328P_ADC_NONE;
          }
          signal ReadStream.readDone (failed ? FAIL : SUCCESS, usActualPeriod);
        }
        break;
      }
      default:
        atomic op = ATM328P_ADC_NONE;
        break;
    }
  }


  async event void Adc.done ()
  {
    op_mode_t mode;

    atomic mode = op;

    if (mode == ATM328P_ADC_READNOW)
    {
      uint8_t id = client;
      uint16_t val = call Adc.get ();
      atomic op = ATM328P_ADC_NONE;
      signal ReadNow[id].readDone (SUCCESS, val);
    }
    else if (mode == ATM328P_ADC_READSTREAM)
    {
      atomic {
        buffer[buffer_used++] = call Adc.get ();

        if (buffer_used == buffer_count)
        {
          if (done_buffer) // uh-oh, we haven't signalled the last buffer!
          {
            read_stream_done_pending = TRUE;
            read_stream_failed = TRUE;
            call Adc.disableAutoTrigger ();
            post adc_task ();
            return;
          }

          // save for bufferDone signaling
          done_buffer = buffer;
          done_count = buffer_count;

          buffer = next_buffer (client);
          if (buffer)
          {
            buffer_count = buffer[1];
            buffer_used = 0;
          }
          else
          {
            call Adc.disableAutoTrigger ();
            read_stream_done_pending = TRUE;
          }
        }
      }

      if (done_buffer)
        post adc_task ();
    }
    else
      post adc_task ();
  }
}
