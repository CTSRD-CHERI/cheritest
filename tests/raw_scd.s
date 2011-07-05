.set mips64
.set noreorder
.set nobopt
.set noat

#
# Unit test that stores double words to, and then loads double words from,
# memory using store conditional.  Interruption behaviour is deferred to a
# higher-level test.
#

		.text
start:
		#
		# Store conditional only works against addresses in cached
		# memory.  Calculate a cached address for our data segment,
		# and store pointer in $gp.
		#

		dla	$gp, dword
		dli	$t0, 0x9000000000000000		# Uncached
		dsubu	$gp, $gp, $t0
		dli	$t0, 0x9800000000000000		# Cached, non-coherenet
		daddu	$gp, $gp, $t0

		# Store and load a double word into double word storage
		dli	$a0, 0xfedcba9876543210
		scd	$a0, 0($gp)			# @dword
		ld	$a1, 0($gp)

		# Store and load double with sign extension
		daddiu	$gp, $gp, 8			# @positive
		dli	$a2, 1
		scd	$a2, 0($gp)
		ld	$a3, 0($gp)

		daddiu	$gp, $gp, 8			# @negative
		dli	$a4, -1
		scd	$a4, 0($gp)
		ld	$a5, 0($gp)

		# Store and load double words at non-zero offsets
		daddiu	$gp, $gp, 8			# @val1
		dli	$a6, 2
		scd	$a6, 8($gp)
		ld	$a7, 8($gp)

		daddiu	$gp, $gp, 8			# @val2
		dli	$s0, 1
		scd	$s0, -8($gp)
		ld	$s1, -8($gp)

		# Dump registers in the simulator
		mtc0	$v0, $26
		nop
		nop

		# Terminate the simulator
	        mtc0 $v0, $23
end:
		b end

		.data
dword:		.dword	0x0000000000000000
positive:	.dword	0x0000000000000000
negative:	.dword	0x0000000000000000
val1:		.dword	0x0000000000000000
val2:		.dword	0x0000000000000000
