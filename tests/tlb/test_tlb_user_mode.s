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

# Simple TLB test which configures a TLB entry for the lowest virtual
# page in the user address space and attempts a to execute code in it,
# returning via a system call.

.set mips64
.set noreorder
.set nobopt

.global test
test:   .ent    test
		daddu	$sp, $sp, -16
		sd	$ra, 8($sp)
		sd	$fp, 0($sp)
		daddu	$fp, $sp, 16

		jal     bev_clear
		nop
		
		# Install exception handler
		dla	$a0, exception_handler
		jal 	bev0_handler_install
		nop		
	
 		dmtc0	$zero, $5               # Write 0 to page mask i.e. 4k pages
		dmtc0	$zero, $0		# TLB index 
		dmtc0	$zero, $10		# TLB entryHi

		dla     $a0, testcode		# Load address of testdata in bram
		and     $a2, $a0, 0xffffffe000	# Get physical page (PFN) of testcode (40 bits less 13 low order bits)
		dsrl    $a3, $a2, 6		# Put PFN in correct position for EntryLow
		or      $a3, 0x1a   		# Set valid and global bits, cached
		dmtc0	$a3, $2			# TLB EntryLow0
		daddu 	$a4, $a3, 0x40		# Add one to PFN for EntryLow1
		dmtc0	$a4, $3			# TLB EntryLow1
		tlbwi				# Write Indexed TLB Entry

		dli	$a5, 0			# Initialise test flag
	
		and     $k0, $a0, 0xfff		# Get offset of testdata within page.
		jr 	$k0			# Jump to virtual address
		nop

after_syscall:	
		ld	$ra, 8($sp)
		ld	$fp, 0($sp)
		jr      $ra
		daddu	$sp, $sp, 16
.end    test
	
testcode:
        .rept 10
		nop
        .endr
                beqz    $a5, testcode
		add	$a5, 1			# Set the test flag
		syscall
		nop

exception_handler:
		dla	$t0, after_syscall
		jr	$t0
		nop
