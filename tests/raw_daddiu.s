.set mips64
.set noreorder
.set nobopt
.set noat

#
# Simple test for daddiu -- not intended to rigorously check arithmetic
# correctness, rather, register behaviour and instruction interpretation.
# Overflow is left to higher-level tests, as exceptions are implied.
#

start:
		#
		# add with independent input and output; preserve input for
		# test framework so we can check it wasn't improperly
		# modified.
		#
		dli	$a0, 1
		daddiu	$a1, $a0, 1

		#
		# add with input as the output
		#
		dli	$a2, 1
		daddiu	$a2, $a2, 1

		#
		# Feed output of one straight into the input of another.
		#
		dli	$a3, 1
		daddiu	$a3, $a3, 1
		daddiu	$a3, $a3, 1

		#
		# check that immediate is sign-extended
		#
		dli	$a4, 1
		daddiu	$a4, $a4, -1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
