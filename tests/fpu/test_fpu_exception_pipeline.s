#-
# Copyright (c) 2011 Robert M. Norton
# Copyright (c) 2013 Michael Roe
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
# These are regression tests to check that CP2 operations which entered the
# pipeline after an exception is triggered are correctly squashed and do
# not update any CP2 state. Earlier version of the CHERI prototype did not
# handle this correctly.
#
# For each test, an instruction which causes an exception is immediately followed
# by a capability operation. Check to see that the capability
# state is not updated, even though capability modification instruction will
# have entered the pipeline.

		.global test
test:		.ent test
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32
	
		#
		# Set up exception handler.
		#

		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
                nop
	
		#
        	# Enable CP1 
		#

	        dli $t1, 1 << 29
		mfc0 $t0, $12
        	or $t0, $t0, $t1 
	    	mtc0 $t0, $12 
        	nop
        	nop
        	nop

		lui $t0, 0x3f80	# 1.0
		mtc1 $t0, $f1

		dli	$t0, 0
		syscall	0
		# The following instruction should NOT be executed because the
		# handler will return to syscall + 8
		mtc1	$t0, $f1

		nop
		nop
		nop
		nop

		mfc1 $a0, $f1

		lui	$t0, 0x3f80	# 1.0
		mtc1	$t0, $f1
		li	$t0, 0
		mtc1	$t0, $f2

		syscall 0
		# The following instruction should not be executed
		add.s	$f2, $f1, $f1

		nop
		nop
		nop

		mfc1	$a1, $f2

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler
#
# Returns to the instruction two after the faulting one.
#

		.ent bev0_handler
bev0_handler:
		dmfc0	$k0, $14	# EPC
		daddiu	$k0, $k0, 8 	# EPC += 8 to bump PC forward on ERET N.B. 8 because we wish to skip instruction after svc!
		dmtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
