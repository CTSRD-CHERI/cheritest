# cheritest
Replacement for the cheritest SVN repository.

cheritest is a comprehensive framework for testing the BERI and CHERI MIPS processor.

## Getting started

* Clone this repository.
* Get the cherisdk from jenkins, which you can find at ctsrd-build.cl.cam.ac.uk. You can find the SDK here: toolchain->CHERI-SDK->jemalloc,vanilla,cheri128,linux
* Run the following to test BERI: `TEST_CP2=0 CLANG=0 GENERIC_L1=1 NOFUZZR=1 BERI=1 TRACE=0 CHERI_SDK=<path_to_sdk> CHERIROOT=<path_to_ctsrd_svn>/cheri/trunk/ CHERILIBS=<path_to_ctsrd_svn>/cherilibs/trunk/ make nosetest_cached`

## Running individual tests
To run individual test simply remove the corresponding log file from the log directory and run `make log/<test_to_run>.log`
