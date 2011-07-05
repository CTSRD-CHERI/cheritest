.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise the 'nor' instruction.
#

start:
		# Test here
		dli	$t0, 0x0000000000000000
		dli	$t1, 0x0000000000000000
		nor	$a0, $t0, $t1
		dli	$t0, 0xffffffffffffffff
		dli	$t1, 0x0000000000000000
		nor	$a1, $t0, $t1
		dli	$t0, 0x0000000000000000
		dli	$t1, 0xffffffffffffffff
		nor	$a2, $t0, $t1
		dli	$t0, 0xffffffffffffffff
		dli	$t1, 0xffffffffffffffff
		nor	$a3, $t0, $t1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
