module McuSleepC {
  provides {
    interface McuSleep;
    interface McuPowerState;
  }
}
implementation {
  async command void McuSleep.sleep() {
    sei ();
    asm volatile ("sleep" : : : "memory");
    cli ();
  }

  async command void McuPowerState.update() {
  }
}
