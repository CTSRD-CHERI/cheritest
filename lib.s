.set mips64
.set noreorder
.set nobopt
.set noat

#
# POSIX-like void *memcpy(dest, src, len), arguments taken as a0, a1, a2,
# return value via v0.  Uses t0 to hold the in-flight value.
#

		.text
		.global memcpy
		.ent memcpy
memcpy:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		move	$v0, $a0	# Return initial value of dest.

memcpy_loop:
		lb	$t0, 0($a1)
		nop			# XXXRW: Work around load-to-store
		nop			# race in CHERI.
		sb	$t0, 0($a0)

		# Increment dest and src, decrement len
		daddiu	$a0, 1
		daddiu	$a1, 1
		daddiu	$a2, -1
		bnez	$a2, memcpy_loop	# loop until done
		nop			# branch-delay slot

		ld	$fp, 16($fp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end memcpy
