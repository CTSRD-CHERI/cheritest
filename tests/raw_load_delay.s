.set mips64
.set noreorder
.set nobopt
.set noat

#
# Load from an address into reg a1, and then immediately move the value into
# a second register.  MIPS 4400 doesn't require (although does encourage)
# load delay slots.  By varying the number of NOPs, we can see how far a
# (possible) bug in pipeline might exist.
#

		.text
start:
		# No NOP
		dla	$a0, dword0
		ld	$a1, 0($a0)
		move	$t0, $a1

		# One NOP
		dla	$a0, dword1
		ld	$a1, 0($a0)
		nop
		move	$t1, $a1

		# Two NOPs
		dla	$a0, dword2
		ld	$a1, 0($a0)
		nop
		nop
		move	$t2, $a1

		# Three NOPs
		dla	$a0, dword3
		ld	$a1, 0($a0)
		nop
		nop
		nop
		move	$t3, $a1

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
	        break
end:
		b end

		#
		# Pad out data so that each double word gets its own cache
		# line, ensuring maximum stall in the memory subsystem.
		#
		.data
		.align 5
dword0:		.dword	0xfedcba9876543210
		.align 5
dword1:		.dword	0xfedcba9876543210
		.align 5
dword2:		.dword	0xfedcba9876543210
		.align 5
dword3:		.dword	0xfedcba9876543210
