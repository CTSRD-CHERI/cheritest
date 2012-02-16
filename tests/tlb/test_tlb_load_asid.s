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

# Simple TLB test which configures a TLB entry for lowest virtual
# page in xuseg with two different ASIDs and attempts to load via
# both of them.

.set mips64
.set noreorder
.set nobopt

.global test
test:   .ent    test
		dli     $k0, 0x0
 		dmtc0	$k0, $5                 # Write 0 to page mask i.e. 4k pages
		dla     $a0, testdata1		# Load address of testdata in bram
		dla     $a1, testdata2		# Load address of testdata in bram

		# Set up TLB entry for testdata1
		dmtc0	$zero, $0		        # TLB index = 0
		li      $at, 1			      # ASID=1
		dmtc0	$at, $10		        # TLB HI address (BRAM) Virtual address (first page, ASID=1) 63:62 == 00 means kernel user address space
		and     $a2, $a0, 0xffffffe000	# Get physical page (PFN) of testdata (40 bits less 13 low order bits)
		dsrl    $a2, $a2, 6		   # Put PFN in correct position for EntryLow
		or      $a2, 0x12   		   # Set valid and uncached bits
		dmtc0	$a2, $2			        # TLB EntryLow0 = a2 (Low half of TLB entry for even virtual address (VPN))
		dmtc0	$zero, $3		        # TLB EntryLow1 = 0 (invalid)
		tlbwi				              # Write Indexed TLB Entry
	
		# Set up TLB entry for testdata2
		li      $at, 1
		dmtc0	$at, $0			# TLB index = 1
		li      $at, 2 			# ASID=2
		dmtc0	$at, $10		# TLB HI address (BRAM) Virtual address (first page, ASID=2) 63:62 == 00 means kernel user address space
		and     $a3, $a1, 0xffffffe000	# Get physical page (PFN) of testdata (40 bits less 13 low order bits)
		dsrl    $a3, $a3, 6		# Put PFN in correct position for EntryLow
		or      $a3, 0x12   		# Set valid and uncached bits
		dmtc0	$a3, $2			# TLB EntryLow0 = a3 (Low half of TLB entry for even virtual address (VPN))
		dmtc0	$zero, $3		# TLB EntryLow1 = 0 (invalid)
		tlbwi				# Write Indexed TLB Entry	

		li      $at, 2
		dmtc0   $at, $10                # ASID=2
    nop
    nop
    nop
    nop
    nop
    nop
		ld      $a4, 0($0)		# Test read from virtual address.

		li      $at, 1
		dmtc0   $at, $10                # ASID=1
    nop
    nop
    nop
    nop
    nop
    nop
		ld      $a5, 0($0)		# Test read from virtual address.
	
		jr      $ra
		nop
.end    test
	
	.data
	.align 13 # Align to the start of an even page for easy access
testdata1:
	.dword 0xfedcba9876543210
	.align 13 # Put testdata2 at start of next even page.
testdata2:
	.dword 0x0123456789abcdef