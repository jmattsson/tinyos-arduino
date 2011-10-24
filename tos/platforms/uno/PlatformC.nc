configuration PlatformC {
  provides interface Init;
}
implementation {
  components PlatformP;
  Init = PlatformP.Init;
}

