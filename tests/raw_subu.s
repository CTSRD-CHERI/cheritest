.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for subu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# subu with independent inputs and outputs; preserve inputs
		# for test framework so we can check they weren't improperly
		# modified.
		#
		li	$s3, 2
		li	$s4, 1
		subu	$a0, $s3, $s4

		#
		# subu with first input as the output
		#
		li	$a1, 2
		li	$t0, 1
		subu	$a1, $a1, $t0

		#
		# subu with second input as the output
		#
		li	$t0, 2
		li	$a2, 1
		subu	$a2, $t0, $a2

		#
		# subu with both inputs the same as the output
		#
		li	$a3, 1
		subu	$a3, $a3, $a3

		#
		# Feed output of one straight into the input of another.
		#
		li	$t0, 5
		li	$t1, 3
		li	$t2, 1
		subu	$t3, $t0, $t1
		subu	$a4, $t3, $t2

		#
		# Even though subu arithmetic is "unsigned", in 64-bit mode,
		# registers are still sign-extended.
		#
		li	$t0, 1
		li	$t1, 1
		subu	$a5, $t0, $t1	# to 0x0000000000000000

		li	$t0, -1
		li	$t1, 1
		subu	$a6, $t0, $t1	# to 0xfffffffffffffffe

		li	$t0, -1
		li	$t1, -2
		subu	$a7, $t0, $t1	# to 0x0000000000000001

		li	$t0, 1
		li	$t1, 2
		subu	$s0, $t0, $t1	# to 0xffffffffffffffff

		#
		# Muck around with higher 32 bits in a way that should be
		# masked in the output due to sign extension at 32 bits.
		#
		dli	$t0, 0x0010000000000002		# top 32b -> 0's
		dli	$t1, 0x0000000000000001
		subu	$s1, $t0, $t1

		dli	$t0, 0xffefffffffffffff		# top 32b -> 1's
		dli	$t1, 0x0000000000000001
		subu	$s2, $t0, $t1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
