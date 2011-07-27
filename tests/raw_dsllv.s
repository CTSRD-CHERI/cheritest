.set mips64
.set noreorder
.set nobopt
.set noat

#
# Tests the Doubleword Shift Left Logical Variable instruction which is a 64-bit instruction
# Any extra padding added on the right should be zero 
#

start:
		dli	$a0, 0xfedcba9876543210

		li	$a1, 0
		dsllv	$a1, $a0, $a1

		li	$a2, 1
		dsllv	$a2, $a0, $a2

		li	$a3, 16
		dsllv	$a3, $a0, $a3

		li	$a4, 32
		dsllv	$a4, $a0, $a4

		li	$a5, 43
		dsllv	$a5, $a0, $a5

		li	$a6, 63
		dsllv	$a6, $a0, $a6

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
