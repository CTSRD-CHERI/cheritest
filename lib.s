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
		sb	$t0, 0($a0)

		# Increment dest and src, decrement len
		daddiu	$a0, 1
		daddiu	$a1, 1
		daddiu	$a2, -1
		bnez	$a2, memcpy_loop	# loop until done
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end memcpy

#
# Install an exception handler at address a0, which unconditionally jumps
# back to the address passed via a1.  a2, t0, and v0 also stepped on by
# memcpy().
#

		.data
handler_target:
		.dword	0x0
		.text

		.global handler_install
		.ent handler_install
handler_install:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Store the caller's handler in 'handler_target' to be found
		# later by handler_stub.
		sd	$a1, handler_target

		# Install our handler_stub in exception handler memory
		# specified by the caller.
		dli	$a2, 8 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		dla	$a1, handler_stub
		jal memcpy
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end handler_install


#
# Position-independent exception handler that jumps to an address specified
# via handler_install.  Steps on $k0.
#

		.global handler
		.ent handler_stub
handler_stub:
		ld	$k0, handler_target
		jr	$k0
		nop
		.end handler_stub
