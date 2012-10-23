#-
# Copyright (c) 2011 Michael Roe
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
# Test csci with a negative immediate offset
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Tweak capability type field so that we can tell if type and
		# base are in the right order.
		#
		dli	$t0, 0x1
		csettype	$c2, $c2, $t0

		#
		# Set the permissions field so we can tell if it is stored
		# at the right place in memory. The permissions are
		# Non_Ephemeral, Permit_Execute, Permit_Load, Permit_Store,
		# Permit_Store_Capability, Permit_Load_Capability,
		# Permit_Store_Ephemeral.
		#
		dli $t0, 0x7f
		candperm $c2, $c2, $t0

		#
		# Make $c1 a data capability for cap1
		#
		dla $t0, cap1
		cincbase $c1, $c0, $t0

		#
		# Store at cap1 in memory.
		#
		dli     $t0, 8
		csc	$c2, $t0, -8($c1)

		#
		# Load back in as general-purpose registers to check values
		#
		dla	$t0, cap1
		# $a0 will be the perms field (0x7f) shifted left one bit,
		# plus the u bit (0x1) giving 0xff.
		ld	$a0, 0($t0)
		ld	$a1, 8($t0)
		ld	$a2, 16($t0)
		ld	$a3, 24($t0)

		# Check that underflow or overflow didn't occur
		dla	$t1, underflow
		ld	$a4, 0($t1)
		dla	$t1, overflow
		ld	$a5, 0($t1)

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align	5		# Must 256-bit align capabilities
		.dword	0x0
		.dword	0x0
		.dword	0x0
underflow:	.dword	0x0123456789abcdef
cap1:		.dword	0x0123456789abcdef	# uperms/reserved
		.dword	0x0123456789abcdef	# otype/eaddr
		.dword	0x0123456789abcdef	# base
		.dword	0x0123456789abcdef	# length
overflow:	.dword	0x0123456789abcdef	# check for overflow
		.dword	0x0
		.dword	0x0
		.dword	0x0
