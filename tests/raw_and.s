.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise the 'and' instruction.
#

start:
		# Test here
		dli	$t0, 0x0000000000000000
		dli	$t1, 0x0000000000000000
		and	$a0, $t0, $t1
		dli	$t0, 0xffffffffffffffff
		dli	$t1, 0x0000000000000000
		and	$a1, $t0, $t1
		dli	$t0, 0x0000000000000000
		dli	$t1, 0xffffffffffffffff
		and	$a2, $t0, $t1
		dli	$t0, 0xffffffffffffffff
		dli	$t1, 0xffffffffffffffff
		and	$a3, $t0, $t1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
