.set mips64
.set noreorder
.set nobopt
.set noat

#
# Check that 32-bit and 64-bit load immediates of negative numbers work as
# expected.  The former implies a sign extension on load.
#

start:
		# Test here
		li	$a0, -1
		dli	$a1, -1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
