.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for dsubu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# dsubu with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		dli	$s3, 2
		dli	$s4, 1
		dsubu	$a0, $s3, $s4

		#
		# dsubu with first input as the output
		#
		dli	$a1, 2
		dli	$t0, 1
		dsubu	$a1, $a1, $t0

		#
		# dsubu with second input as the output
		#
		dli	$t0, 2
		dli	$a2, 1
		dsubu	$a2, $t0, $a2

		#
		# dsubu with both inputs the same as the output
		#
		dli	$a3, 1
		dsubu	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		dli	$t0, 5
		dli	$t1, 3
		dli	$t2, 1
		dsubu	$t3, $t0, $t1
		dsubu	$a4, $t3, $t2

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
