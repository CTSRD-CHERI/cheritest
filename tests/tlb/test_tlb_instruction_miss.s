#-
# Copyright (c) 2012 Robert N. M. Watson
# Copyright (c) 2012 Jonathan Woodruff
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
#.set noat

#
# Test that a very simple TLB handler using the automatically filled EntryHi will work as expected.
#

		.global test
test:		.ent test
		daddu 		$sp, $sp, -32
		sd		$ra, 24($sp)
		sd		$fp, 16($sp)
		daddu		$fp, $sp, 32

		jal		bev_clear
		nop

		#
		# Set up 'handler' as the RAM exception handler.
		# Note that we set up both common and xtlb handlers
		# because the first miss (with EXL=1) will go to
		# the common handler but subsequent misses (following eret)
		# will go to xtlb miss.
		#
		dla	$a0, bev0_handler
		jal	set_bev0_common_handler
		nop

		dla	$a0, bev0_handler
		jal	set_bev0_xtlb_handler
		nop

		#
		# Clear registers we'll use when testing results later.
		#
		dla		$a4, mapped_code
		dli		$a2, 0xFFFFFFFF
		and		$a4, $a2, $a4
		dli		$a3, 0
		dli		$a5, 0
		jalr	$a4
		dli		$a6, 0
		dla		$a1, return
		jr		$a1
		nop
		
		#
		# Instructions to run mapped.
		#
mapped_code:
		jr		$31
		dli		$a5, 0xbeef
	
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
tlb_stuff:
		dmfc0	$t0, $8					# Get bad virtual address
		move	$a6, $t0				# Get bad virtual address
		dmfc0	$a7, $14				# Get victim address
		dli 	$t3, 0xFFFFE000			# Mask off the page offset
		and		$t0, $t0, $t3
		dror	$a2, $t0, 6             # Put PFN in correct position for EntryLow
		or		$a2, 0x17				# Set valid and uncached bits
		dmtc0   $a2, $2					# TLB EntryLow0 = a2 (Low half of TLB entry for even virtual $
		ori		$a2, 0x1000				# Set the 13th bit for to insert the upper physical address
		dmtc0   $a2, $3					# TLB EntryLow1 = a2 (Upper half of TLB entry for even virtual $
		nop
		nop
		nop
		nop
		tlbwr								# Write Random

		nop			# NOPs to avoid hazard with ERET
		nop			# XXXRW: How many are actually
		nop			# required here?
		nop
		eret
		.end bev0_handler
