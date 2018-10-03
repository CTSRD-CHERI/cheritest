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


### Writing tests


Tests should generally use the new macros that avoid copy-pasted code from getting out of sync.

Example:

```asm
.include "macros.s"

# Comment describing the test

BEGIN_TEST
	#
	# test code ...
	#
	# On exit the register $v0 will contain the number of traps that happenend
	# And register $k1 will contain information about the last trap (unless the test modified it
	# it should be zero if no exceptions were triggered)
END_TEST
```

```python
from beritest_tools import BaseBERITestCase, attr, HexInt

@attr("capabilities")
class test_foo(BaseBERITestCase):
    def test_trap_info(self):
        # Use python asserts instead of self.assertRegisterEqual() since pytest gives much more detailed
        # output on failures if you use them
        # By default pytest will print int values as decimal. To avoid this use HexInt() from beritest_tools
        assert self.MIPS.c1.offset == HexInt(0x12345)
        # Note: unlike self.assertRegisterEqual() the assertion above will also print the full value of
        # $c1 which is very useful for debugging tests

    # TODO: this should be part of BaseBERITestCase!
    def test_trap_count(self):
        assert self.MIPS.v0 == 0, "This test should not have trapped"
        self.assertTrapInfoNoTrap(self.MIPS.k1, "This test should not have trapped")
```

### Writing tests with custom trap handlers

Don't copy the existing tests with custom trap handlers since they usually make failures annoying to debug.
Instead use the BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER macro and use the "compressed trap info" utility functions
in python since they will not only print "something went wrong" but also specify why the trap you got was wrong.

An example of such a new test is e.g. `test/cp0/test_cp0_badinstr`.


```asm
BEGIN_TEST_WITH_CUSTOM_TRAP_HANDLER
	# Put test code here
END_TEST

BEGIN_CUSTOM_TRAP_HANDLER
	# Custom trap handler logic:

	# Recommended: save the information on the trap handler in a register
	# so that python code can test it (see below)
	# Note: this will also set the number of times that the trap handler has been invoked in $v0
	collect_compressed_trap_info $a4

	#
	# More trap handler logic
	#

	#
	# Now return from trap handler:
	#
	# Examples: eret or just jump to finish
	#

	# jumping to finish will end the test:
	dla $k0, finish
	jr $k0

	# Or continue using eret:
	dla $k0, new_epc
	dmtc0	$k0, $14	# update EPC
	DO_ERET			# This macro ensures that cp0 state has synced before eret
END_CUSTOM_TRAP_HANDLER
```

```python
from beritest_tools import BaseBERITestCase, attr

@attr("capabilities")
class test_foo(BaseBERITestCase):
    def test_trap_info(self):
        # Test for a syscall trap (see MipsStatus.Cause for all the constants):
        self.assertCompressedTrapInfo(self.MIPS.a4, mips_cause=self.MIPS.Cause.SYSCALL, trap_count=1)

    def test_trap_info_2(self):
        # Test that we got a CHERI length violation on register $c6:
        # See MipsStatus.CapCause for all the constants
        self.assertCp2Fault(self.MIPS.a5, cap_cause=self.MIPS.CapCause.Length_Violation,
                            trap_count=1, cap_reg=6, msg="... should have failed with a length violation!")

    def test_trap_info_3(self):
        # Test that an operation doesn't trap (ensure you clear trap info register first)
        self.assertTrapInfoNoTrap(self.MIPS.a6, "... should not have trapped")

    def test_trap_count(self):
        assert self.MIPS.v0 == 4, "expected four traps"
```
