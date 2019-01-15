#include "cheri_c_test.h"

extern "C" int printf(const char*, ...);

class TestFactoryBase {
public:
	virtual void *CreateTest() { return nullptr; };
};

class TestFactoryImpl : public TestFactoryBase {
public:
	void *CreateTest() override;
	int data;
};

void *HandleExceptionsInMethodIfSupported(TestFactoryBase *object, void *(TestFactoryBase::*method)());

#ifdef BUILD_IMPLEMENTATION
void *TestFactoryImpl::CreateTest() {
	DEBUG_MSG("CreateTest called\n");
	printf("CreateTest called\n");
	return &data;
}

void *HandleExceptionsInMethodIfSupported(TestFactoryBase *object, void *(TestFactoryBase::*method)()) {
  return (object->*method)();
}
#else

BEGIN_TEST(clang_purecap_memberptr)
  __asm__ volatile("csetdefault $cnull");
  TestFactoryBase *factory = new TestFactoryImpl();
  void* result = HandleExceptionsInMethodIfSupported(factory, &TestFactoryBase::CreateTest);
  assert(result != 0);
END_TEST

#endif
