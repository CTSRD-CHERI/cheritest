.set mips64
.set noreorder
.set nobopt
.set noat

#
# Tests the Shift Left Logical Variable instruction which is a 32-bit instruction
# Any extra padding added on the right should be zero 
# There should be sign extension in the 32-bit result for the upper 32 bits
#

start:
		dli	$a0, 0xfedcba9876543210

		li	$a1, 0
		sllv	$a1, $a0, $a1

		li	$a2, 1
		sllv	$a2, $a0, $a2

		li	$a3, 16
		sllv	$a3, $a0, $a3

		li	$a4, 31
		sllv	$a4, $a0, $a4

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
