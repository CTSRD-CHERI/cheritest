#-
# Copyright (c) 2011 Robert N. M. Watson
# All rights reserved.
#
# This software was developed by SRI International and the University of
# Cambridge Computer Laboratory under DARPA/AFRL contract (FA8750-10-C-0237)
# ("CTSRD"), as part of the DARPA CRASH research programme.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

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
# Functions to install exception handlers for general-purpose exceptions when
# BEV=0 and BEV=1.  The handler to install is at address a0, and will be
# jumped to unconditionally.
#
# This function invokes memcpy(), which will stop on a2, t0, and v0.
#

		.data
bev0_handler_target:
		.dword	0x0
bev1_handler_target:
		.dword	0x0
		.text

		.global bev0_handler_install
		.ent bev0_handler_install
bev0_handler_install:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Store the caller's handler in bev0_handler_target to be
		# found later by bev0_handler_stub.
		dla	$t2, bev0_handler_target
		sd	$a0, 0($t2)

		# Install our bev0_handler_stub at the MIPS-specified
		# exception vector address.
		dli	$a0, 0xffffffff80000180
		dla	$a1, bev0_handler_stub
		dli	$a2, 8 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev0_handler_install


		.global bev1_handler_install
		.ent bev1_handler_install
bev1_handler_install:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Store the caller's handler in bev1_handler_target to be
		# found later by bev1_handler_stub.
		dla	$t2, bev1_handler_target
		sd	$a0, 0($t2)

		# Install our bev1_handler_stub at the MIPS-specified
		# exception vector address.
		dli	$a0, 0xffffffffbfc00380
		dla	$a1, bev1_handler_stub
		dli	$a2, 8 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev1_handler_install

#
# Position-independent exception handlers that jump to an address specified
# via {bev0, bev1}_handler_install.  Steps on $k0.
#

		.ent bev0_handler_stub
bev0_handler_stub:
		ld	$k0, bev0_handler_target
		jr	$k0
		nop
		.end bev0_handler_stub

		.ent bev1_handler_stub
bev1_handler_stub:
		ld	$k0, bev1_handler_target
		jr	$k0
		nop
		.end bev1_handler_stub

#
# Configure post-boot exception vectors by clearing the BEV bit in the CP0
# status register.  Stomps on t0 and t1.
#
		.text
		.global bev_clear
		.ent bev_clear
bev_clear:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		mfc0	$t0, $12
		dli	$t1, 1 << 22	# BEV bit
		nor	$t1, $t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev_clear
