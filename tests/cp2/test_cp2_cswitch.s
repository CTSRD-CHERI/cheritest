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
# Macro test that checks whether we can save and restore the complete
# capability register file.  All loads and stores are performed via $c30
# ($kdc).  This replicates the work an operating system would perform in
# order to ensure that an OS would work!
#

		.global test
test:		.ent test
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Save out all capability registers but $kcc and $kdc.
		#
		dla	$t0, data
		cscr	$c0, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c1, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c2, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c3, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c4, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c5, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c6, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c7, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c8, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c9, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c10, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c11, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c12, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c13, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c14, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c15, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c16, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c17, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c18, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c19, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c20, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c21, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c22, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c23, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c24, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c25, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c26, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c27, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c28, $c30, $t0

		daddiu	$t0, $t0, 32
		cscr	$c31, $c30, $t0

		#
		# Now reverse the process.
		#
		dla	$t0, data
		clcr	$c0, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c1, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c2, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c3, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c4, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c5, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c6, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c7, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c8, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c9, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c10, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c11, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c12, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c13, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c14, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c15, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c16, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c17, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c18, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c19, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c20, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c21, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c22, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c23, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c24, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c25, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c26, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c27, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c28, $c30, $t0

		daddiu	$t0, $t0, 32
		clcr	$c31, $c30, $t0

		.end test

		#
		# 32-byte aligned storage for 30 adjacent capability
		# registers.
		#
		.data
		.align 5
data:		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c0
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c1
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c2
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c3
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c4
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c5
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c6
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c7
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c8
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c9
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c10
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c11
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c12
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c13
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c14
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c15
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c16
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c17
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c18
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c19
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c20
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c21
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c22
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c23
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c24
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c25
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c26
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c27
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c28
		.dword	0x0011223344556677, 0x8899aabbccddeeff
		.dword	0x0011223344556677, 0x8899aabbccddeeff	# c31
		.dword	0x0011223344556677, 0x8899aabbccddeeff
