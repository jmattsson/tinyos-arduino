#include <stdio.h>

module TestP {
  uses interface Boot;
  uses interface VariantPool as VPool;
#include <unittest/module_spec.h>
} implementation {
#include <unittest/module_impl.h>

#define POOL_SIZE (64 - 2)

  void assert_available (size_t size)
  {
    void *t;
    size_t lt = 0;
    t = call VPool.reserve (&lt);
    ASSERT_TRUE(t != NULL);
    ASSERT_TRUE(lt = size);
    call VPool.release (t);
  }

  event void Boot.booted () {
    void *a1, *a2, *a3;
    size_t l1, l2, l3;

    // Reserve full pool
    a1 = call VPool.reserve (&l1);
    ASSERT_TRUE(a1 != NULL);
    ASSERT_EQUAL(l1, POOL_SIZE);

    // Reserve from empty pool
    l2 = 0xfade;
    a2 = call VPool.reserve (&l2);
    ASSERT_TRUE(!a2);
    ASSERT_EQUAL(l2, 0xfade); // a failed reserve should not touch len ptr

    // Alloc from empty pool
    a2 = call VPool.alloc (1);
    ASSERT_TRUE(!a2);
    ASSERT_EQUAL(l2, 0xfade); // a failed alloc should not touch len ptr

    // Reduce reservation
    l1 = 4;
    call VPool.reduce (a1, l1);
    a2 = call VPool.reserve (&l2);
    ASSERT_TRUE(a2 != NULL);
    ASSERT_EQUAL(l2, POOL_SIZE - l1 - 2);

    // Alloc from empty pool
    l3 = 1;
    a3 = call VPool.alloc (l3);
    ASSERT_TRUE(!a3);

    // Reduce reservation
    l2 = 15;
    call VPool.reduce (a2, l2);

    // Alloc from pool
    l3 = 34;
    a3 = call VPool.alloc (l3);
    ASSERT_TRUE(a3 != NULL);

    // Release in order a3, a1, a2 to exercise most merge scenarios
    call VPool.release (a3);
    assert_available (POOL_SIZE - l1 - l2 - 2*2);

    call VPool.release (a1);
    // a1 was only a small unmerged chunk, should have no impact on reserve
    assert_available (POOL_SIZE - l1 - l2 - 2*2);

    call VPool.release (a2);
    assert_available (POOL_SIZE);

    ALL_TESTS_PASSED();
  }
}
