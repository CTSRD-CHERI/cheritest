.set mips64
.set noreorder
.set nobopt
.set noat

#
# Tests the Shift Left Logical instruction which is a 32-bit instruction
# Any extra padding added on the right should be zero
# There should be sign extension in the 32-bit result for the upper 32 bits
#

start:
		dli	$a0, 0xfedcba9876543210
		sll	$a1, $a0, 0
		sll	$a2, $a0, 1
		sll	$a3, $a0, 16
		sll	$a4, $a0, 31

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
