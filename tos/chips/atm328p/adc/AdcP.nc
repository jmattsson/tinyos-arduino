#include "Atm328pTimerConfig.h"
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
    interface Alarm<ATM328P_TIMER_1_PRECISION_TYPE, uint16_t>;
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

  op_mode_t op = ATM328P_ADC_NONE;
  uint8_t client;
  uint16_t *spare = 0; // list of spare buffers
  norace uint16_t *buffer = 0, buffer_count = 0, buffer_used = 0;
  uint16_t *done_buffer = 0, done_count = 0;

  uint32_t usActualPeriod;
  uint16_t alarm_dt;

  bool read_stream_done_pending;
  bool read_stream_failed;


  void apply_configuration (const Atm328pAdcConfig_t *cfg)
  {
    if (!cfg)
      return;
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
        next = (uint16_t **)&buf[0];
    }
    return 0;
  }

  void disable_stream_interrupts ()
  {
    atomic {
      call Adc.disableAutoTrigger ();
      call Alarm.stop ();
      call Adc.disableInterrupt ();
    }
  }

  void calculate_alarm_interval (uint32_t usPeriod)
  {
    uint16_t max_period = 0xffffu >> ATM328P_TIMER_1_MICRO_DOWNSCALE;
    usActualPeriod = (usPeriod > max_period) ? max_period : usPeriod;
    atomic alarm_dt = usActualPeriod << ATM328P_TIMER_1_MICRO_DOWNSCALE;
  }


  command error_t Read.read[uint8_t id] ()
  {
    atomic {
      if (op != ATM328P_ADC_NONE || call Adc.isConverting ())
        return EBUSY;

      op = ATM328P_ADC_READ;
      client = id;
    }

    apply_configuration (call AdcConfigure.getConfiguration[id] ());
    call Adc.startConversion ();

    return SUCCESS;
  }


  async command error_t ReadNow.read[uint8_t id] ()
  {
    atomic {
      if (!call Resource.isOwner[id] ())
        return FAIL;
      if (op != ATM328P_ADC_NONE || call Adc.isConverting ())
        return EBUSY;

      op = ATM328P_ADC_READNOW;
      client = id;
    }

    apply_configuration (call AdcConfigure.getConfiguration[id] ());
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

  command error_t ReadStream.read[uint8_t id] (uint32_t usPeriod)
  {
    atomic {
      if (op != ATM328P_ADC_NONE)
        return EBUSY;
      buffer = next_buffer (id);
      if (!buffer)
        return ENOMEM;

      buffer_count = buffer[1];
      buffer_used = 0;

      op = ATM328P_ADC_READSTREAM;
      client = id;

      read_stream_done_pending = FALSE;
      read_stream_failed = FALSE;
    }

    apply_configuration (call AdcConfigure.getConfiguration[id] ());
    calculate_alarm_interval (usPeriod);
    call Adc.setAutoTriggerSource (ATM328P_ADC_TRIGGER_TIMER1_COMP_B);
    call Adc.enableAutoTrigger ();
    call Alarm.start (alarm_dt);

    return SUCCESS;
  }


  task void adc_task ()
  {
    op_mode_t mode;
    uint8_t id;

    atomic {
      id= client;
      mode = op;
    }

    switch (mode)
    {
      case ATM328P_ADC_READ:
      {
        uint16_t val = call Adc.get ();
        atomic op = ATM328P_ADC_NONE;
        signal Read.readDone[id] (SUCCESS, val);
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
          signal ReadStream.bufferDone[id] (SUCCESS, buf, count);

        if (failed)
        {
          signal ReadStream.bufferDone[id] (FAIL, buffer, buffer_used);
          while ((buf = next_buffer (id)))
            signal ReadStream.bufferDone[id] (FAIL, buf, 0);
        }

        if (done)
        {
          atomic {
            read_stream_done_pending = FALSE;
            buffer = 0;
            buffer_used = buffer_count = 0;
            op = ATM328P_ADC_NONE;
          }
          signal
            ReadStream.readDone[id] (failed ? FAIL : SUCCESS, usActualPeriod);
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

    call Adc.disableInterrupt();

    if (mode == ATM328P_ADC_READNOW)
    {
      uint8_t id = client;
      uint16_t val = call Adc.get ();
      call Adc.disableInterrupt ();
      atomic op = ATM328P_ADC_NONE;
      signal ReadNow.readDone[id] (SUCCESS, val);
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
            disable_stream_interrupts ();
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
            disable_stream_interrupts ();
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

  async event void Alarm.fired ()
  {
    atomic {
      if (op == ATM328P_ADC_READSTREAM)
      {
        call Adc.enableInterrupt ();
        call Alarm.startAt (call Alarm.getAlarm (), alarm_dt);
      }
    }
  }

  event void Resource.granted[uint8_t id] () {}


  default async command const Atm328pAdcConfig_t *AdcConfigure.getConfiguration[uint8_t id] ()
  {
    return 0;
  }

  default async event void ReadNow.readDone[uint8_t id] (error_t res, uint16_t val) {}

  default event void Read.readDone[uint8_t id] (error_t res, uint16_t val) {}
  default event void ReadStream.bufferDone[uint8_t id] (error_t res, uint16_t *buf, uint16_t c) {}
  default event void ReadStream.readDone[uint8_t id] (error_t res, uint32_t usp) {}

}
