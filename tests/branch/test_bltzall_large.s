#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2013 Jonathan Woodruff
# Copyright (c) 2014 Michael Roe
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

#
# Test bltzall with an offset of 4- 131072.
# This is a regression test for a bug found by fuzz testing.
#

.set mips64
.set noreorder
.set nobopt
.set noat

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Copy the routine at 'target' to an address in RAM where
		# there is enough memory for the large jump offset.
		#

		dli	$a0, 0x9800000010000000
		dla	$a1, target
		dli	$a2, 0x80
		jal	memcpy
		nop	# Branch delay slot

		#
		# Copy the routine 'branch' at the desired offset from 'branch'
		#

		dli	$a0, 0x9800000010000000 + 131072 - 4
		dla	$a1, branch
		dli	$a2, 0x80
		jal	memcpy
		nop	# Branch delay slot

		#
		# Clear $a2 so we can tell if the branch ends up at the right
		# place.
		#

		dli	$a2, 0

		#
		# Load $a1 with a negative value, so the branch will be taken.
		#

		dli	$a1, -1

		#
		# Jump to the copy of 'branch'
		#

		dli	$a0, 0x9800000010000000 + 131072 - 4
		jr	$a0
		nop

target:
		dli	$a2, 0x1234
		b	out
		nop			# Branch delay slot

branch:
		bltzall	$a1, .-131072+4
		nop			# Branch delay slot

out:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

