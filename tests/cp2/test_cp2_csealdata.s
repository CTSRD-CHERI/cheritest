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
# Test csealdata
#

# In this test, sandbox isn't actually called, but its address is used
# as an otype.
sandbox:
		creturn

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

                # Make $c1 a template capability for a user-defined type
		# whose otype is equal to the address of sandbox.
		dla      $t0, sandbox
		csettype $c1, $c0, $t0

                # Make $c2 a data capability for the array at address data
		dla      $t0, data
		cincbase $c2, $c0, $t0
                dli      $t0, 8
                csetlen  $c2, $c2, $t0
		# Permissions Non_Ephemeral, Permit_Load, Permit_Store,
		# Permit_Store.
		# NB: Permit_Execute must not be included in the set of
		# permissions used here.
		dli      $t0, 0xd
		candperm $c2, $c2, $t0

		# Seal data capability $c2 to the otype of $c1, and store
		# result in $c3.
                csealdata $c3, $c2, $c1

                # $c3.u should be 0
		cgetunsealed $a0, $c3
                # $c3.type should be equal to sandbox
		cgettype $a1, $c3
		dla      $t0, sandbox
		dsubu    $a1, $a1, $t0
                # $c3.base should be equal to data
                cgetbase $a2, $c3
                dla      $t0, data
                dsubu    $a2, $t0
	        # $c3.len should be equal to $c2.len, i.e. 8	
                cgetlen  $a3, $c3
                # $c3.perm should be equal to $c2.perms
		cgetperm $a4, $c3

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align 3
data:		.dword	0xfedcba9876543210
