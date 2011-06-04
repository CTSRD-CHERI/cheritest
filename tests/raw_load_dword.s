.set mips64
.set noreorder
.set nobopt
.set noat

#
# Regression test that loads a double word from memory.
#
		.text
start:
		ld	$t0, dword

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		.data
dword:		.dword	0xfedcba9876543210
