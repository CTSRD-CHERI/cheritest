.set mips64
.set noreorder
.set nobopt
.set noat

#
# Regression test that stores a word to, and then loads a word from memory.
#
		.text
start:
		dli	$t0, 0xfedcba98
		sw	$t0, dword
		lw	$t1, dword

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		.data
dword:		.dword	0x0000000000000000
