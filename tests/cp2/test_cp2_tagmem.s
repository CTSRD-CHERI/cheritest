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
# Perform a few basic tests involving capability register length: query the
# starting length of $c2, reduce the length, and query it again.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		dla	$t0, cap1
		cmove   $c1, $c0
                cscr     $c1, $t0($c0)
                clcr     $c2, $t0($c0)
                cgettag $a0, $c2
                ccleartag $c1
                cscr     $c1, $t0($c0)
                clcr     $c2, $t0($c0)
                cgettag $a1, $c1
                
                # Exercise a potential victim buffer in the tag cache.
                dla	$t1, cap1-0x4000000	# A conflicting address
                dla	$t2, cap1+0x1000	# A different address
                cmove	$c1, $c0
                # Store a valid cap to an address that conflicts with one in the cache.
                cscr	$c1, $t1($c0)
                # Load data from the old address, swapping with the victim buffer.
                clcr	$c2, $t0($c0)
                # Load another address, evicting the victim buffer
		clcr	$c3, $t2($c0)
		# Load the evicted address to see if it has the tag set
		clcr	$c1, $t1($c0)
		cgettag	$a2, $c1

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

		.data
		.align	5                  # Must 256-bit align capabilities
cap1:		.dword	0x0123456789abcdef # uperms/reserved
		.dword	0x0123456789abcdef # otype/eaddr
		.dword	0x0123456789abcdef # base
		.dword	0x0123456789abcdef # length

