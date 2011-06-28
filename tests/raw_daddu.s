.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for daddu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# daddu with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		dli	$s3, 1
		dli	$s4, 2
		daddu	$a0, $s3, $s4

		#
		# daddu with first input as the output
		#
		dli	$t0, 1
		dli	$a1, 2
		daddu	$a1, $a1, $t0

		#
		# daddu with second input as the output
		#
		dli	$t0, 1
		dli	$a2, 2
		daddu	$a2, $t0, $a2

		#
		# daddu with both inputs the same as the output
		#
		dli	$a3, 1
		daddu	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		dli	$t0, 1
		dli	$t1, 2
		dli	$t2, 3
		daddu	$t3, $t0, $t1
		daddu	$a4, $t3, $t2

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
