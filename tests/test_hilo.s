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

#
# Test for 'HI' and 'LO' registers used with integer multiply and divide.  The
# goal of this test is to make sure that data flow in and out of the registers
# is working as intended, not to fully exercise multiply or divide.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Check that we can load values into, and extract values out
		# of HI and LO for context switching purposes.
		#
		dli	$t0, 0xe624379d7daf6318
		mthi	$t0
		dli	$t1, 0x608467ffc8a78552
		mtlo	$t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a2
		mflo	$a3

		#
		# Do a single multiply operation.  We are interested only in
		# whether an answer pops out in the registers.
		#
		dli	$t0, 0x4c1de53737a475d3
		dli	$t1, 0x0ed59e2102fc6a4e
		dmult	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a4
		mflo	$a5

		#
		# And likewise, a single divide operation.
		#
		# XXXRW: SDE as for MIPS insists on including break/trap code
		# for divide by zero when ddiv is used.  It would be nice to
		# turn that off.  Until we figure out how, the .noat above
		# will cause this ddiv instruction to generate a warning.
		#
		dli	$t0, 0x5568a2865eb2ee3e
		dli	$t1, 0x2ac0abc68a41800e
		ddiv	$t0, $t1

		# Mandated double-nop between reads and writes
		nop
		nop

		mfhi	$a6
		mflo	$a7

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
