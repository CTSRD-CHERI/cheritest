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
# Test to check that PCC/EPCC swapping on exception entry/return is correct.
# We use a non-exception trap instruction to drive the test, since we don't
# want to depend on capability exceptions working (yet).
#
# To this end, run a portion of this test with an alternative PCC able only
# to address a limited portion of address space between 'sandbox_begin' and
# 'sandbox_end'.  The linker uses global addresses, so that piece of code is
# (moderately) carefully hand-crafted to avoid global references.  We trap
# once to get in, and once to get out.
#
# Outputs to check:
#
# $a0 - exception counter (should be 2)
# $a1 - set to 1 before first trap (should be 1)
# $a2 - set to 1 after first trap (should be 1)
# $a3 - queried $ra within sandbox (should be 0x10)
# $a4 - set to 1 after second trap (should be 1)
# $a5 - linker-provided return address following sandbox restore (no check)
# $a6 - queried $ra after sandbox (should be equal to a5)
#
# $a7 - saved base of sandbox
# $s0 - saved length of sandbox (should be roughly 24)
#
# $s1 - cause register from last trap (should be TRAP)
# $s2 - EPC register from last trap (should be 0x10)
#
# $c2 - saved EPCC from first trap (before sandbox)
#     - perms from EPCC on first trap (should be 0x7fff)
#     - type from EPCC on first trap (should be 0x0)
#     - base from EPCC on first trap (should be 0x0)
#     - length from EPCC on first trap (should be 0xffffffffffffffff)
#
# $c3 - saved EPCC from second trap (in sandbox)
#     - perms from EPCC on second trap (should be 0x0001)
#     - type from EPCC on second trap (should be 0)
#     - base from EPCC on second trap (should be equal to $a7)
#     - length from EPCC on second trap (should be equal to $s0)
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up 'handler' as the RAM exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, exception_handler
		jal	bev0_handler_install
		nop

		#
		# Initialise trap counter.
		#
		dli	$a0, 0

		#
		# Prepare $c1 to point at the space between 'sandbox_begin'
		# and 'sandbox_end'.  Restrict to Non_Ephemeral and
                # Permit_Execute permissions.
		#
		dli	$t0, 0x0003
		candperm	$c1, $c1, $t0
		dla	$a7, sandbox_begin
		cincbase	$c1, $c1, $a7

		#
		# Calculate desired length of $c1 into $s0, then set the length.
		#
		dla	$t0, sandbox_end
		dsubu	$s0, $t0, $a7

		csetlen	$c1, $c1, $s0

		#
		# First trap -- on return, we will be running relative to the
		# new $c1.
		#
		dli	$a1, 1		# Pre-trap
		teq	$zero, $zero

		#
		# In this window, working with a modified PCC.  We cannot
		# rely on any linker-calculated addresses as a result.
		#
		# NOTE: the number of instructions in this window is
		# hard-coded into test_cp2_exception_epcc.py.  If you change
		# it here, remember to change it there!
		#
sandbox_begin:
		dli	$a2, 1		# 0x0: Address space transformed

		#
		# To confirm we are running with a modified PCC, query PC
		# using a minimalist JALR.
		#
		dli	$t0, 0xc	# 0x04
		jalr	$t0		# 0x08
		nop			# 0x0c	Branch-delay slot
		move	$a3, $ra	# 0x10

		#
		# Second trap -- on return, we will be restored to a global
		# PCC.  Linker-calculated addresses can be used safely again.
		#
		teq	$zero, $zero	# 0x10
sandbox_end:
		dli	$a4, 1		# Address space restored

		#
		# To confirm that we are running with a restored PCC, query
		# PC using a minimalist JALR.
		#
		dla	$a5, restored_ra
		jalr	$a5
		nop
restored_ra:
		move	$a6, $ra

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test



#
# Exception handler, which relies on the installation of KCC into PCC in order
# to run.  This code assumes that the trap was not in a branch delay slot.
#
		.ent exception_handler
exception_handler:
		# Capture cause register so we can make sure that an
		# exception was thrown for the right reason!
		dmfc0	$s1, $13	# Get cause register

		daddiu	$a0, $a0, 1	# Increment trap counter

		# If the trap counter is 1, jump to install sandbox.
		dli	$k0, 1
		beq	$a0, $k0, install_sandbox
		nop

		# Save old EPCC
		cmove	$c3, $c31

		# Remove sandboxing
		cmove	$c31, $c0	# Move $c0 into $epcc

		# Save sandbox EPC for later inspection
		dmfc0	$s2, $14

		# Set EPC to continue after exception return
		dla	$k0, sandbox_end
		dmtc0	$k0, $14

		b	exception_done
		nop

install_sandbox:
		# Save old EPCC
		cmove	$c2, $c31

		# Install sandboxing
		cmove	$c31, $c1

		# Set up new PC -- offset 0
		dmtc0	$zero, $14	# Set EPC

exception_done:
		nop			# Avoid CP0 hazards with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		nop
		nop
		nop
		eret
		.end exception_handler
