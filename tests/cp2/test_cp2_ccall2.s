#-
# Copyright (c) 2012 Michael Roe
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
# Test ccall followed by creturn
#

sandbox:
		dli	$a2, 42
		creturn

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up exception handler
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Set up trap handler for CCall/CReturn
		#

		dli	$a0, 0xffffffff80000280
		dla	$a1, bev0_ccall_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop			# branch-delay slot

                #
                # Create a capability for the trusted system stack
                #

                dla     $t0, trusted_system_stack
                cincbase $c1, $c0, $t0
                dli     $t0, 96
                csetlen $c1, $c1, $t0
                dla     $t0, tsscap
                cscr    $c1, $t0($c0)

                #
                # Initialize the pointer into the trusted system stack
                #

                dla     $t0, tssptr
                dli     $t1, 0
                csdr    $t1, $t0($c0)

		#
                # Make $c4 a template capability for a user-defined type
		# whose otype is equal to the address of sandbox.
		#

		dla      $t0, sandbox
		csettype $c4, $c0, $t0

		#
                # Make $c3 a data capability for the array at address data
		#

		dla      $t0, data
		cincbase $c3, $c0, $t0
                dli      $t0, 8
                csetlen  $c3, $c3, $t0
		# Permissions Non_Ephemeral, Permit_Load, Permit_Store,
		# Permit_Store.
		# NB: Permit_Execute must not be included in the set of
		# permissions used here.
		dli      $t0, 0xd
		candperm $c3, $c3, $t0

		#
		# Seal data capability $c3 to the otype of $c4, and store
		# result in $c2.
		#

                csealdata $c2, $c3, $c4

		#
		# Make $c1 a code capability for sandbox
		#

		csealcode $c1, $c4

		#
		# Move $c0 into IDC ($c26) so that it will be saved onto
		# the trusted system stack by ccall
		#

		cmove $c26, $c0

		#
		# Clear $c0 so that the sandbox doesn't have access to it
		#

		ccleartag $c0

		#
		# Invoke the sandbox
		#

		ccall   $c1, $c2
		nop			# branch delay slot

		#
		# Restore $c0 from the IDC ($c26) that has been popped off
		# the trusted system stack by creturn
		#

		cmove $c0, $c26

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		cgetcause $a3
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop
		nop
		nop
		nop
		eret
		.end bev0_handler

		.ent bev0_ccall_handler
bev0_ccall_handler:
		cgetcause $k0
		srl	$k0, $k0, 8
		addi	$k0, $k0, -5
		beq	$k0, $zero, do_ccall
		addi	$k0, $k0, -1
		beq	$k0, $zero, do_creturn

		#
		# The opcode wasn't recognized
		#

		dmfc0   $k0, $14
		daddiu  $k0, $k0, 4 # Bump EPC forward one instruction
		dmtc0   $k0, $14
		nop
		nop
		nop
		nop
		eret

do_ccall:
                #
                # Load a capability for the trusted system stack into
                # kernel reserved capability register 2 ($c28)
                #
                # $c27 should already be a capability for the kernel's
                # data segment
                #

                dla     $k0, tsscap
                clcr    $c28, $k0($c27)

                #
                # Make $k0 the current offset into the trusted system stack
                #

                dla     $k0, tssptr
                cldr    $k0, $k0($c27)

		#
		# Push the IDC on to the trusted system stack
		#

		csc	$c26, $k0, 0($c28)

		#
		# Push EPCC (the user's PCC) on to the trusted system stack
		#

		csc	$c31, $k0, 32($c28)

		#
		# Bump the EPC (user's PC) by 1 instruction (4 bytes) and
		# push it on to the trusted system stack
		#

		dmfc0	$t0, $14	# XXX: corrupts $t0
		daddi	$t0, $t0, 4
		csd	$t0, $k0, 64($c28)

		#
		# Move $c1.otype into EPC, so that when we return it will be
		# to the entry point of the invoked sandbox
		#

		cgettype $t0, $c1	# XXX : assumes ccall $c1, $c2
		dmtc0   $t0, $14
		nop
		nop
		nop
		nop
		eret

do_creturn:
                #
                # Load a capability for the trusted system stack into
                # kernel reserved capability register 2 ($c28)
                #
                # $c27 should already be a capability for the kernel's
                # data segment
                #

                dla     $k0, tsscap
                clcr    $c28, $k0($c27)

                #
                # Make $k0 the current offset into the trusted system stack.
                #

                dla     $k0, tssptr
                cldr    $k0, $k0($c27)

		#
		# Pop the IDC ($c26) off the trusted system stack
		#

		clc	$c26, $k0, 0($c28)

                #
                # Pop the EPCC off the trusted system stack, so it will
                # restored to the user's PCC when this exception handler
                # returns to user space.
                #

                clc     $c31, $k0, 32($c28)

                #
                # Pop the return address off the trusted system stack into
                # EPC, so it will be returned to when this exception handler
                # returns to user space.
                #

                cld    $k0, $k0, 64($c28)
                dmtc0   $k0, $14

                nop
                nop
                nop
                nop
                eret
		.end bev0_ccall_handler

		.ent bev0_ccall_handler_stub
bev0_ccall_handler_stub:
		dla     $k0, bev0_ccall_handler
		jr      $k0
		nop
		.end bev0_ccall_handler_stub

		.data
                .align 3
tssptr:
                .dword 0

                .align 5
tsscap:
                .dword 0
                .dword 0
                .dword 0
                .dword 0

                .align 5
trusted_system_stack:
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0
                .dword 0

		.align 3
data:		.dword	0xfedcba9876543210
