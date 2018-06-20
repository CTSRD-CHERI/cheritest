# cheritest
Replacement for the cheritest SVN repository.

cheritest is a comprehensive framework for testing the BERI and CHERI MIPS processor.

## Getting started

* Clone this repository.
* Get the cherisdk from jenkins, which you can find at ctsrd-build.cl.cam.ac.uk. You can find the SDK here: toolchain->CHERI-SDK->jemalloc,vanilla,cheri128,linux
* Run the following to test BERI: `TEST_CP2=0 CLANG=0 GENERIC_L1=1 NOFUZZR=1 BERI=1 TRACE=0 CHERI_SDK=<path_to_sdk> CHERIROOT=<path_to_ctsrd_svn>/cheri/trunk/ CHERILIBS=<path_to_ctsrd_svn>/cherilibs/trunk/ make nosetest_cached`

## Running individual tests
### QEMU:
Run `make CAP_SIZE=128/256 <OTHER_FLAGS> pytest/qemu/tests/foo/test_foo.py`

### Simulator:
Run `make CAP_SIZE=128/256 <OTHER_FLAGS> pytest/sim_cached/tests/foo/test_foo.py`
There are also targets `pytest/sim_uncached/*` for uncached tests, `pytest/sim_multi/*` (uncached multi) and `pytest/sim_cachedmulti/*` (cached multi).

### L3:
Run `make CAP_SIZE=128/256 <OTHER_FLAGS> pytest/l3_cached/tests/foo/test_foo.py`
There are also targets `pytest/l3_uncached/*` for uncached tests, `pytest/l3_multi/*` (uncached multi) and `pytest/l3_cachedmulti/*` (cached multi).

### Just the test .log file:
To run individual test simply remove the corresponding log file from the log directory and run `make log/<test_to_run>.log`. For QEMU this is `make CAP_SIZE=256 qemu_log/256/<test_to_run>.log` or `make CAP_SIZE=128 qemu_log/128/<test_to_run>.log`

