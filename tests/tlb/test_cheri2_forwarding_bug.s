#-
# Copyright (c) 2012 Robert N. M. Watson
# Copyright (c) 2013 Jonathan D. Woodruff
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
# Test derived from test_tlb_exception_fill which demonstrates a forwarding
# bug once observed on cheri2.
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32


                # Set up a TLB entry
                dli     $a0, 0x1017
                dli     $a1, 0x1057        
        
                dmtc0   $zero, $10                                      # TLB EntryHigh
		dmtc0   $a0, $2						# TLB EntryLow0
		dmtc0   $a1, $3						# TLB EntryLow1
		nop
		nop
		nop
		nop
		tlbwr							# Write Random

        
		#
		# Clear registers we'll use when testing results later.
		#
		dli	$a2, 0
		dli	$a3, 0
		dli	$a4, 0
		dli	$a5, 0
		dli	$a6, 0
		
		#
		# Do a loop that will write pages of virtual address space,
		# Then read those back and count the number of non-matches.
		#
		dli $a3, 64
		dli $a4, 0
write_loop:
		sd $a4, 0($a4)
		daddi $a4, $a4, 64
		bnez $a3, write_loop
		daddi $a3, $a3, -64
		
		dli $a3, 64
read_loop:
		daddi $a4, $a4, -64
		ld $a5, 0($a4)
		beq $a5, $a4, skip_add  # <-- This branch experiences forwarding bug from load
		nop
		addi $a6, $a6, 1
skip_add:
		bnez $a3, read_loop
		daddi $a3, -64
	
return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test
