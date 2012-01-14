configuration TestAppC {
} implementation {
  components TestP;
  components MainC;

  TestP.Boot -> MainC;
  
  components new VariantPoolC (64) as VPool;
  TestP.VPool -> VPool;

#include <unittest/config_impl.h>
}
