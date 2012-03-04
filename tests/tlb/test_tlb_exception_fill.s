#-
# Copyright (c) 2012 Robert N. M. Watson, Jonathan D. Woodruff
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
# Test that a very simple TLB handler using the automatically filled EntryHi will work as expected.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Set up 'handler' as the RAM exception handler.
		#
		jal	bev_clear
		nop
		dla	$a0, bev0_handler
		jal	bev0_handler_install
		nop

		#
		# Save the desired EPC value for this exception so we can
		# check it later.
		#
		dla	$a0, desired_epc

		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a1, 5
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0

		#
		# Set up a taken branh with a trap instruction in the
		# branch-delay slot.  EPC should point at the branch, not the
		# trap instruction.
		#
		li	$t0, 1
desired_epc:
		sd	$a1, 0($zero)
		#
		# Exception return.  If EPC is 4 too high, due to not
		# handling the branch-delay slot right, $a6 will be set but
		# not $a1.
		#
		ld	$a2, 0($zero)
return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler.  This exception handler sets EPC to the original victim instruction,
# inserts a valid EntryLo for the first physical page of memory, and uses the automatically
# generated EntryHi value to write the TLB.  This is the fast-path, and the general scheme
# used in FreeBSD.
#
		.ent bev0_handler
bev0_handler:
		li	$a2, 1
		mfc0	$a3, $12	# Status register
		mfc0	$a4, $13	# Cause register
		dmfc0	$a5, $14	# EPC
		#daddi	$k0, $a5, -4	# EPC -= 4 to bump PC forward on ERET
		#dmtc0	$k0, $14
tlb_stuff:
                dsrl    $a2, $0, 6                 # Put PFN in correct position for EntryLow with physical address of 0
                or	$a2, 0x17                      # Set valid and uncached bits
                dmtc0   $a2, $2                    # TLB EntryLow0 = a2 (Low half of TLB entry for even virtual $
                dmtc0   $zero, $3                  # TLB EntryLow1 = 0 (invalid)
                tlbwr				   # Write Random
                mtc0 $at, $25

		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
