.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for add -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# add with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		li	$s3, 1
		li	$s4, 2
		add	$a0, $s3, $s4

		#
		# add with first input as the output
		#
		li	$t0, 1
		li	$a1, 2
		add	$a1, $a1, $t0

		#
		# add with second input as the output
		#
		li	$t0, 1
		li	$a2, 2
		add	$a2, $t0, $a2

		#
		# add with both inputs the same as the output
		#
		li	$a3, 1
		add	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		li	$t0, 1
		li	$t1, 2
		li	$t2, 3
		add	$t3, $t0, $t1
		add	$a4, $t3, $t2

		#
		# simple exercises for signed arithmetic
		#
		li	$t0, 1
		li	$t1, -1
		add	$a5, $t0, $t1	# to zero

		li	$t0, -1
		li	$t1, -1
		add	$a6, $t0, $t1	# to negative

		li	$t0, -1
		li	$t1, 2
		add	$a7, $t0, $t1	# to positive

		li	$t0, 1
		li	$t1, -2
		add	$s0, $t0, $t1	# to negative

		#
		# Muck around with higher 32 bits in a way that should be
		# masked in the output due to sign extension at 32 bits.
		#
		dli	$t0, 0x0010000000000000		# top 32b -> 0's
		dli	$t1, 0x0000000000000001
		add	$s1, $t0, $t1

		dli	$t0, 0xffeffffffffffffe		# top 32b -> 1's
		dli	$t1, 0x0000000000000001
		add	$s2, $t0, $t1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
