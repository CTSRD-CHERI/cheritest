.set mips64
.set noreorder
.set nobopt
.set noat

#
# Regression test that stores a half word to, and then loads a half word from
# memory.
#
		.text
start:
		dli	$t0, 0xfedc
		sh	$t0, dword
		lh	$t1, dword

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
