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

# Simple TLB test which configures a TLB entry for the highest virtual
# page in xkseg/kseg3 and attempts a load via it.

.set mips64
.set noreorder
.set nobopt

.global test
test:   .ent    test
		dli     $k0, 0x0
 		dmtc0	$k0, $5                 # Write 0 to page mask i.e. 4k pages
		dla     $a0, testdata		# Load address of testdata in bram

		dli 	$k0, 0			# TLB index
		dmtc0	$k0, $0			# TLB index = k0

		dli     $a1 , (0xfffffffffffff000) # TLB HI address (top page of kseg3)
		dmtc0	$a1, $10		# TLB HI address = a1

		and     $a2, $a0, 0xffffffe000	# Get physical page (PFN) of testdata (40 bits less 13 low order bits)
		dsrl    $a3, $a2, (12-6)	# Put PFN in correct position for EntryLow
		or      $a3, 0x13   		# Set valid and global bits, uncached
		dmtc0	$zero, $2		# TLB EntryLow0 = invalid
		dmtc0	$a3, $3			# TLB EntryLow1 = a3
		tlbwi				# Write Indexed TLB Entry

		and     $k0, $a0, 0xfff		# Get offset of testdata within page.
		daddu   $k0, $k0, $a1		# Construct an address in kernel user space.
		nop							# Delay for tlb update to take effect
		nop

		ld      $a5, 0($k0)			# Test read from virtual address.

		jr      $ra
		nop
.end    test
	
	.data
	.align 5
testdata:
	.dword 0xfedcba9876543210
