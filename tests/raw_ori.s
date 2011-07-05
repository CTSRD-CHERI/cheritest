.set mips64
.set noreorder
.set nobopt
.set noat

#
# Exercise the 'ori' instruction.
#

start:
		# Test here
		dli	$t0, 0x0000000000000000
		ori	$a0, $t0, 0x0000
		dli	$t0, 0xffffffffffffffff
		ori	$a1, $t0, 0x0000
		dli	$t0, 0x0000000000000000
		ori	$a2, $t0, 0xffff
		dli	$t0, 0xffffffffffffffff
		ori	$a3, $t0, 0xffff

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
