#-
# Copyright (c) 2012 Robert M. Norton
# All rights reserved.
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

# TLB test which configures a TLB entry and attempts a store via it,
# but without setting the valid bit. This should result in a TLB
# Invalid exception which differs from a TLB Refill exception
# in the vector user.

# Register usage:
# a0: paddr of testdata
# a1: PFN of testdata
# a2: EntryLo0 value
# a3: EntryLo1 value
# a4: Vaddr of testdata
# a5: Result of load 
# a6: Expected PC of faulting instruction
# a7: Final value of testdata
	
# s0: BadVAddr
# s1: Context
# s2: XContext
# s3: EntryHi
# s4: Status
# s5: Cause
# s6: EPC
	
.set mips64
.set noreorder
.set nobopt

page=0xafa # A randomly chosen (even) page
	
.global test
test:   .ent    test
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
		dla	$a6, desired_epc

	
 		dmtc0	$zero, $5               # Write 0 to page mask i.e. 4k pages
		dmtc0	$zero, $0		# TLB index
		li      $t0, (page<<12)
		dmtc0	$t0, $10		# TLB HI address
	
		dla     $a0, testdata		# Load address of testdata in bram
		and     $a1, $a0, 0xffffffe000	# Get physical page (PFN) of testdata (40 bits less 13 low order bits)
		dsrl    $a2, $a1, 6		# Put PFN in correct position for EntryLow
		or      $a2, 0x11   		# Set valid and global bits, uncached
		dmtc0	$a2, $2			# TLB EntryLow0 = k0 (Low half of TLB entry for even virtual address (VPN))
		daddu 	$a3, $a2, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$a3, $3			# TLB EntryLow1 = k0 (Low half of TLB entry for odd virtual address (VPN))
		tlbwi				# Write Indexed TLB Entry

		nop
		nop
		nop
		and     $a4, $a0, 0xfff		# Get offset of testdata within page.
		add     $a4, (page<<12)	        # Add page number
desired_epc:	sd      $a5, 0($a4)		# Load from virtual address
		ld      $a7, 0($a0)		# Check that the store didn't work...
return:
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

#
# Exception handler.  
#
		.ent bev0_handler
bev0_handler:
		dmfc0   $s6, $14      		# EPC
		daddu   $t0, $s6, 4		# Increment EPC
		dmtc0   $t0, $14		# and store it back
		dmfc0	$s0, $8			# BadVAddr
		dmfc0	$s1, $4			# Context
		dmfc0	$s2, $20		# XContext
		dmfc0	$s3, $10		# EntryHi
		dmfc0   $s4, $12	      	# Status
		dmfc0	$s5, $13		# Cause
		eret
		.end bev0_handler
	
	.data
	.align 5
testdata:
	.dword 0xfedcba9876543210
