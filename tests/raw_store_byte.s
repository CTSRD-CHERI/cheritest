.set mips64
.set noreorder
.set nobopt
.set noat

#
# Regression test that stores a byte to, and then loads a byte from memory.
#
		.text
start:
		dli	$t0, 0xfe
		sb	$t0, dword
		lb	$t1, dword

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
