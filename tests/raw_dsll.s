.set mips64
.set noreorder
.set nobopt
.set noat

#
# Tests the Doubleword Shift Left Logical instruction which is a 64-bit instruction
# Any extra padding added on the right should be zero 
#

start:
		dli	$a0, 0xfedcba9876543210
		dsll	$a1, $a0, 0
		dsll	$a2, $a0, 1
		dsll	$a3, $a0, 16
		dsll	$a4, $a0, 31

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end
