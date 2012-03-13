#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2012 Jonathan D. Woodruff
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

# Simple TLB test which configures a TLB entry for the lowest virtual
# page in the xuseg and attempts a load via it.

.set mips64
.set noreorder
.set nobopt

.global test
test:   .ent    test
		# TLB write of index 6	
 		dmtc0	$zero, $5       	# Write 0 to page mask i.e. 4k pages
 		li	$a0, 0x6
		dmtc0	$a0, $0			# TLB index
		li	$a0, 0x2000
		dmtc0	$zero, $10		# TLB HI address
		li	$a0, 0x3000
		dmtc0	$a0, $2			# TLB EntryLow0 = k0 (Low half of TLB entry for even virtual address (VPN))
		li	$a0, 0x4000
		dmtc0	$a0, $3			# TLB EntryLow1 = k0 (Low half of TLB entry for odd virtual address (VPN))
		tlbwi				# Write Indexed TLB Entry
		
		nop
		nop
		nop
		nop
		
		# Clear the tlb registers
		dmtc0	$zero, $5       	# 0 page mask
		dmtc0	$zero, $0       	# 0 index
		dmtc0	$zero, $10       	# 0 EntryHi
		dmtc0	$zero, $2       	# 0 EntryLo0
		dmtc0	$zero, $3       	# 0 EntryLo1

		nop
		nop
		
		# TLB read of index 6.
		li	$a0, 0x6
		dmtc0	$a0, $0			# TLB index
		nop
		nop
		nop
		tlbr
		
		nop
		nop
		nop
		nop
		nop
		nop
		
		# Gather the results of the tlb read
		dmfc0	$a0, $5       	# 0 page mask
		dmfc0	$a1, $0       	# 0 index
		dmfc0	$a2, $10       	# 0 EntryHi
		dmfc0	$a3, $2       	# 0 EntryLo0
		dmfc0	$a4, $3       	# 0 EntryLo1

		jr      $ra
		nop
.end    test
	
	.data
	.align 5
testdata:
	.dword 0xfedcba9876543210
