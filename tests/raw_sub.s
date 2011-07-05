.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for sub -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# sub with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		li	$s3, 2
		li	$s4, 1
		sub	$a0, $s3, $s4

		#
		# sub with first input as the output
		#
		li	$a1, 2
		li	$t0, 1
		sub	$a1, $a1, $t0

		#
		# sub with second input as the output
		#
		li	$t0, 2
		li	$a2, 1
		sub	$a2, $t0, $a2

		#
		# sub with both inputs the same as the output
		#
		li	$a3, 1
		sub	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		li	$t0, 5
		li	$t1, 3
		li	$t2, 1
		sub	$t3, $t0, $t1
		sub	$a4, $t3, $t2

		#
		# simple exercises for signed arithmetic
		#
		li	$t0, 1
		li	$t1, 1
		sub	$a5, $t0, $t1	# to zero

		li	$t0, -1
		li	$t1, 1
		sub	$a6, $t0, $t1	# to negative

		li	$t0, -1
		li	$t1, -2
		sub	$a7, $t0, $t1	# to positive

		li	$t0, 1
		li	$t1, 2
		sub	$s0, $t0, $t1	# to negative

		#
		# Muck around with higher 32 bits in a way that should be
		# masked in the output due to sign extension at 32 bits.
		#
		dli	$t0, 0x0010000000000002		# top 32b -> 0's
		dli	$t1, 0x0000000000000001
		sub	$s1, $t0, $t1

		dli	$t0, 0xffefffffffffffff		# top 32b -> 1's
		dli	$t1, 0x0000000000000001
		sub	$s2, $t0, $t1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
