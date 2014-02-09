#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2012 Jonathan Woodruff
# Copyright (c) 2012 Robert M. Norton        
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
# Test the watchpoint functionality for load accesses.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
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
		# Clear registers we'll use when testing results later.
		#
		dli	$a0, 0
		dli	$a1, 0
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		dli	$a7, 0
		dli	$s0, 0
		dli	$s1, 0

		#
		# Save the desired EPC value for this exception so we can
		# check it later.
		#
		dla	$a0, testdata
		# Make a watch point at this address
		ori	$a1, $a0, 2     # Set read watch bit
		dmtc0	$a1, $18        # Set watchLo
                dli     $t0, 0x40000000 # Set global bit, zero mask
                dmtc0   $t0, $19        # Set watchHi
		nop
		nop
		nop
		nop
		nop
		nop
		nop

		#
		# Trigger watch 
		#
desired_epc:
                ld      $t0, 0($a0)

                # Note that a store should NOT trigger the watchpoint.
		sd      $t0, 0($a0)
        
		#
		# Exception return.
		#
		li	$a1, 1
		mfc0	$a6, $12	# Status register after ERET

                dmfc0   $a6, $18        # Read back watchLo
                dla     $a7, desired_epc

return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Our actual exception handler, which tests various properties.  This code
# assumes that the overflow wasn't in a branch-delay slot (and the test code
# checks BD as well), so EPC += 4 should return control after the overflow
# instruction.
#
		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0	$a3, $12	# Status register
		mfc0	$a4, $13	# Cause register
		dmfc0	$a5, $14	# EPC
		daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
		dmtc0	$k0, $14
		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler

.data
testdata:
        .dword 0xdeadbeefdeadbeef
