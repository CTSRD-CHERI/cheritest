.set mips64
.set noreorder
.set nobopt
.set noat

#
# Load from an address into reg a1, and then immediately store the value into
# memory.  As per raw_load_delay.s, MIPS 4400 doesn't require (although does
# encourage) load delay slots.  Unlike raw_load_delay.s, this test checks
# that an immediate store to memory works.  By varying the number of NOPs, we
# can see how far a (possible) bug in pipeline might exist.
#

		.text
start:
		# No NOP
		dla	$a0, load0
		dla	$a1, store0
		ld	$a2, 0($a0)
		sd	$a2, 0($a1)

		# One NOP
		dla	$a0, load1
		dla	$a1, store1
		ld	$a2, 0($a0)
		nop
		sd	$a2, 0($a1)

		# Two NOPs
		dla	$a0, load2
		dla	$a1, store2
		ld	$a2, 0($a0)
		nop
		nop
		sd	$a2, 0($a1)

		# Three NOPs
		dla	$a0, load3
		dla	$a1, store3
		ld	$a2, 0($a0)
		nop
		nop
		nop
		sd	$a2, 0($a1)

		# Spacer to let pipeline drain
		nop
		nop
		nop
		nop
		nop
		nop

		# Load results into temporaries for checking
		dla	$a0, store0
		ld	$t0, 0($a0)
		dla	$a0, store1
		ld	$t1, 0($a0)
		dla	$a0, store2
		ld	$t2, 0($a0)
		dla	$a0, store3
		ld	$t3, 0($a0)

		# Spacer to let pipeline drain
		nop
		nop
		nop
		nop
		nop
		nop

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		.data
		.align 5
load0:		.dword	0xfedcba9876543210
load1:		.dword	0xfedcba9876543210
load2:		.dword	0xfedcba9876543210
load3:		.dword	0xfedcba9876543210

		.align 5
store0:		.dword	0
store1:		.dword	0
store2:		.dword	0
store3:		.dword	0
