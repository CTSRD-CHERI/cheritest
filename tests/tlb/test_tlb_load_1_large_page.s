#-
# Copyright (c) 2012 Robert M. Norton
# Copyright (c) 2012 David Chisnall
# Copyright (c) 2013 Jonathan Woodruff
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
		dadd    $s0, $zero, $ra          # Don't save existing s0, init.s doesn't expect it to be preserved

		addi    $a0, $zero, 0            # TLB entry 0
		dla     $a1, testdata            # Physical address testdata
		addi    $a2, $zero, 0x200
		dsll    $a2, 13                  # Virtual address 0x400000
		li	$a3, 0x7FE000            # Page mask of 10 1s, 1024*4k = 4M page
		jal     install_tlb_entry
		nop

		dla	$a1, testdata
		andi	$a1, $a1, 0xFFFF         # Keep the bottom 16 bits of the address
		addi    $a4, $zero, 0x200        # Load testdata via its virtual address into a5
		dsll    $a4, $a4, 13
		or	$a4, $a4, $a1	
		ld      $a6, 0($a4)              # Load testdata into a5 via full TLB lookup 
		ld      $a7, 0($a4)              # Load testdata again via TLB cache
		
		dla	$a1, testdata2
		andi	$a1, $a1, 0xFFFF         # Keep the bottom 16 bits of the address
		addi    $a4, $zero, 0x200        # Load testdata2 via its virtual address into a4
		dsll    $a4, $a4, 13
		or	$a4, $a4, $a1
		ld      $a5, 0($a4)              # Load testdata2 via same page
		ld      $a4, 0($a4)              # Load testdata2 again to test any caching

		jr      $s0
		nop
.end    test
	
	.data
	.align 12                            # Align on 4KB page boundary
testdata:
	.dword 0xfedcba9876543210            # Magic number for the test in page 1
	.space 4088
testdata2:
	.dword 0xba9876543210fead            # Magic number for the test in page 2
