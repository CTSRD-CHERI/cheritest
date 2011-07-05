.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for addi -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# addi with independent input and output; preserve input for
		# test framework so we can check it wasn't improperly
		# modified.
		#
		li	$a0, 1
		addi	$a1, $a0, 1

		#
		# addi with input as the output
		#
		li	$a2, 1
		addi	$a2, $a2, 1

		#
		# Feed output of one straight into the input of another.
		#
		li	$a3, 1
		addi	$a3, $a3, 1
		addi	$a3, $a3, 1

		#
		# check that immediate is sign-extended
		#
		li	$a4, 1
		addi	$a4, $a4, -1

		#
		# simple exercises for signed arithmetic
		#
		li	$a5, 1
		addi	$a5, $a5, -1	# to zero

		li	$a6, -1
		add	$a6, $a6, -1	# to negative

		li	$a7, -1
		addi	$a7, $a7, 2	# to positive

		li	$s0, 1
		add	$s0, $s0, -2	# to negative

		#
		# Muck around with higher 32 bits in a way that should be
		# masked in the output due to sign extension at 32 bits.
		#
		dli	$t0, 0x0010000000000000		# top 32b -> 0's
		addi	$s1, $t0, 1

		dli	$t0, 0xffeffffffffffffe		# top 32b -> 1's
		addi	$s2, $t0, 1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
