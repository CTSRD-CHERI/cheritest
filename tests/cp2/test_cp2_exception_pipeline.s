#-
# Copyright (c) 2011 Robert M. Norton
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
	
		# Test cincbase
		dli	$t0, 0x100
		syscall	0
		# The following instruction should NOT be executed because the
		# handler will return to syscall + 8
		cincbase	$c2, $c2, $t0  # not executed

		# Test csetlen
		dli	$t1, 0x100
		syscall 0
		csetlen	$c3, $c3, $t1  # not executed

		# Test candperm
		dli	$t2, 0x100
		syscall 0
		candperm	$c4, $c4, $t2  # not executed

		# Test csettype
		dli	$t3, 0x100
		syscall 0
		csettype	$c5, $c5, $t3  # not executed

		# Create a test capability for loading and storing
		dli     $t0, 0x100
		cincbase	$c6, $c6, $t0
		csetlen		$c6, $c6, $t0
		candperm	$c6, $c6, $t0
		csettype	$c6, $c6, $t0
		
		# Test cscr
		dla	$t0, data
	        syscall 0
		cscr	$c6, $t0($c0) # not executed
		# If cscr was properly squashed these loads will load the
	        # test values below, otherwise they will get the stored capability
		ld	$a0, ($t0)
		ld	$a1, 8($t0)
		ld	$a2, 16($t0)
		ld	$a3, 24($t0)

		# store the test capability
		cscr	$c6, $t0($c0)
	
		# Test clcr
 		syscall 0
		clcr	$c7, $t0($c0) # not executed

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

# The exception handler just returns to the instruction two after the faulting one.

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

		.data
		.align  5
data:		.dword	0xfeedbeefdeadbeef
		.dword	0xfeedbeefdeadbeef
		.dword	0xfeedbeefdeadbeef
		.dword	0xfeedbeefdeadbeef
