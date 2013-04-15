#-
# Copyright (c) 2011 Robert N. M. Watson
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
# Exercise cache instructions
#
# Execute a series of cache instructions that are found in the kernel.  We
# currently don't check if they are correct, but merely check that they don't
# lock up the processor.  Since we have a write-through L1 cache, the only 
# function of the cache instructions is to synchronize L1 instruction and data
# caches.  We don't currently support cache instructions to the L2.
# 
#

		.global test
test:		.ent test
		daddu 	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		#
		# Retrieve CP0 config register so that test cases can
		# determine expected behaviour for our instruction sequence.
		#
		mfc0	$s1, $16

		#
		# Calculate a physical address of the count register and 
		# save it in $gp.  Various virtual addreses, to be stored 
		# in $t0, will be generated using it.
		#
		dli	$gp, 0x000000007f800000

		#
		# Read via uncached address.
		#
		dli	$t0, 0x9000000000000000
		daddu	$t0, $gp, $t0
		ld	$a0, 0($t0)

		#
		# (1) Read via cached address; brings line into data cache.
		#
		dli	$t0, 0x9800000000000000
		daddu	$t0, $gp, $t0
		ld	$a1, 0($t0)
		
		#
		# (2) series of cache instructions to invalidate data cache and L2 cache lines.  
		#
		cache 0x13, 0($t0)
		cache 0x11, 0($t0)
		
		#
		# (2) Read again via cached address.  Should be updated as it is coming from memory.
		#
		ld	$a2, 0($t0)
		
		#
		# (3) series of cache instructions to invalidate L2 cache lines.  
		#
		cache 0x13, 0($t0)
		
		#
		# (3) Read again via cached address.  Should still be in L1.
		#
		ld	$a3, 0($t0)
		
		#
		# Generate address to writable word.  
		#
		dla  $gp, dword
		dli	$t0, 0x9800000000000000
		dli $t1, 0x00FFFFFFFFFFFFFF
		and $gp, $gp, $t1
		or  $t0, $t0, $gp
		
		#
		# (4) Read initial value of writable word.  
		#
		ld $a4, 0($t0)
		
		#
		# (5) Store new value to writable word.  
		#
		li $t1, 5
		sd $t1, 0($t0)
		
		#
		# (5) writeback and invalidate L2 cache lines.  
		#
		cache 0x01, 0($t0)
		cache 0x03, 0($t0)
		
		#
		# (5) Read written back value of writable word.  
		#
		ld $a5, 0($t0)
		
		#
		# (6) Store new value to writable word.  
		#
		li $t1, 6
		sd $t1, 0($t0)
		
		#
		# (6) Just invalidate L2 cache lines.  
		#
		cache 0x11, 0($t0)
		cache 0x13, 0($t0)
		
		#
		# (6) Read writable word after invalidated write.  
		#
		ld $a6, 0($t0)
		

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end	test

# A double word of data that we will load and store via various
# hardware-defined mappings.
dword:		.dword	0x0123456789abcdef
