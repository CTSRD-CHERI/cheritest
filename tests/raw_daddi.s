.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for daddi -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# daddi with independent input and output; preserve input for
		# test framework so we can check it wasn't improperly
		# modified.
		#
		dli	$a0, 1
		daddi	$a1, $a0, 1

		#
		# daddi with input as the output
		#
		dli	$a2, 1
		daddi	$a2, $a2, 1

		#
		# Feed output of one straight into the input of another.
		#
		dli	$a3, 1
		daddi	$a3, $a3, 1
		daddi	$a3, $a3, 1

		#
		# check that immediate is sign-extended
		#
		dli	$a4, 1
		daddi	$a4, $a4, -1

		#
		# simple exercises for signed arithmetic
		#
		dli	$a5, 1
		daddi	$a5, $a5, -1	# to zero

		dli	$a6, -1
		add	$a6, $a6, -1	# to negative

		dli	$a7, -1
		daddi	$a7, $a7, 2	# to positive

		dli	$s0, 1
		add	$s0, $s0, -2	# to negative

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end
