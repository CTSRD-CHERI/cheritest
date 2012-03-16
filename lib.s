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

# Contants used by lib.s to refer to exception vectors 
EXCV_TLB=0
EXCV_XTLB=8
EXCV_CACHE=16
EXCV_COMMON=24
EXCV_INT=32
EXCV_NUM=5
	
#
# POSIX-like void *memcpy(dest, src, len), arguments taken as a0, a1, a2,
# return value via v0.  Uses t0 to hold the in-flight value.
#

		.text
		.global memcpy
		.ent memcpy
memcpy:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		move	$v0, $a0	# Return initial value of dest.

memcpy_loop:
		# Check up front -- length could start out as zero.
		beq	$a2, $zero, memcpy_done
		nop

		lb	$t0, 0($a1)
		sb	$t0, 0($a0)

		# Increment dest and src, decrement len.
		daddiu	$a0, 1
		daddiu	$a1, 1
		daddiu	$a2, -1

		b memcpy_loop
		nop			# branch-delay slot

memcpy_done:

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end memcpy

#
# Functions to install exception handlers for general-purpose exceptions when
# BEV=0 and BEV=1.  The handler to install is at address a0, and will be
# jumped to unconditionally.
#
# This function invokes memcpy(), which will stop on a2, t0, and v0.
#

		.data
bev0_handler_targets:
	.rept EXCV_NUM
		.dword	0x0
	.endr
bev1_handler_targets:
	.rept EXCV_NUM
		.dword	0x0
	.endr
		.text
.global set_bev0_tlb_handler
.ent set_bev0_tlb_handler
# Set handler for TLB Refill exception when BEV=0
set_bev0_tlb_handler:	
#		dla     $t0, bev0_handler_targets
		sd      $a0, EXCV_TLB($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev0_tlb_handler

.global set_bev1_tlb_handler
.ent set_bev1_tlb_handler
# Set handler for TLB Refill exception when BEV=1
set_bev1_tlb_handler:	
		dla     $t0, bev1_handler_targets
		sd      $a0, EXCV_TLB($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev1_tlb_handler

.global set_bev0_xtlb_handler
.ent set_bev0_xtlb_handler
# Set handler for XTLB Refill exception when BEV=0
set_bev0_xtlb_handler:	
		dla     $t0, bev0_handler_targets
		sd      $a0, EXCV_XTLB($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev0_xtlb_handler

.global set_bev1_xtlb_handler
.ent set_bev1_xtlb_handler
# Set handler for XTLB Refill exception when BEV=1
set_bev1_xtlb_handler:	
		dla     $t0, bev1_handler_targets
		sd      $a0, EXCV_XTLB($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev1_xtlb_handler

.global set_bev0_cache_handler
.ent set_bev0_cache_handler
# Set handler for cache error exception when BEV=0
set_bev0_cache_handler:	
		dla     $t0, bev0_handler_targets
		sd      $a0, EXCV_CACHE($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev0_cache_handler

.global set_bev1_cache_handler
.ent set_bev1_cache_handler
# Set handler for cache error exception when BEV=1
set_bev1_cache_handler:	
		dla     $t0, bev1_handler_targets
		sd      $a0, EXCV_CACHE($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev1_cache_handler

.global set_bev0_common_handler
.ent set_bev0_common_handler
# Set handler for common exception vector when BEV=0
set_bev0_common_handler:	
		dla     $t0, bev0_handler_targets
		sd      $a0, EXCV_COMMON($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev0_common_handler

.global set_bev1_common_handler
.ent set_bev1_common_handler
# Set handler for common exception vector when BEV=1
set_bev1_common_handler:	
		dla     $t0, bev1_handler_targets
		sd      $a0, EXCV_COMMON($t0)
		jr	$ra
		nop # branch-delay slot
.end set_bev1_common_handler

	
.global install_bev0_stubs
.ent install_bev0_stubs
install_bev0_stubs:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Install our bev0_handler_stub at the MIPS-specified
		# exception vector address.
		dli	$a0, 0xffffffff80000000
		dla	$a1, bev0_tlb_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop

		dli	$a0, 0xffffffff80000080
		dla	$a1, bev0_xtlb_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop

		dli	$a0, 0xffffffffa0000100 # NB same same, but different!
		dla	$a1, bev0_cache_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop
	
		dli	$a0, 0xffffffff80000180
		dla	$a1, bev0_common_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot		
.end install_bev0_stubs

.global install_bev1_stubs
.ent install_bev1_stubs
install_bev1_stubs:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Install our bev1_handler_stub at the MIPS-specified
		# exception vector address.
		dli	$a0, 0xffffffffbfc00200
		dla	$a1, bev1_tlb_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop

		dli	$a0, 0xffffffffbfc00280
		dla	$a1, bev1_xtlb_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop

		dli	$a0, 0xffffffffbfc00300
		dla	$a1, bev1_cache_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop
	
		dli	$a0, 0xffffffffbfc00380
		dla	$a1, bev1_common_handler_stub
		dli	$a2, 9 		# 32-bit instruction count
		dsll	$a2, 2		# Convert to byte count
		jal memcpy
		nop			# branch-delay slot

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot		
.end install_bev1_stubs
	
		.global bev0_handler_install
		.ent bev0_handler_install
bev0_handler_install:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		# Store the caller's handler in bev0_handler_target to be
		# found later by bev0_handler_stub.
		jal     set_bev0_common_handler
		nop

		jal     install_bev0_stubs
		nop

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev0_handler_install

		.global bev1_handler_install
		.ent bev1_handler_install
bev1_handler_install:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32
	
		# Store the caller's handler in bev1_handler_target to be
		# found later by bev1_handler_stub.
		jal     set_bev1_common_handler
		nop

		jal     install_bev1_stubs
		nop
	
		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev1_handler_install

#
# Position-independent exception handlers that jump to an address specified
# via {bev0, bev1}_handler_targets[n].  Steps on $k0, which is set to one
# of EXCV_XYZ so that tests can check which vector was used.

		.ent bev0_tlb_handler_stub
bev0_tlb_handler_stub:
		dla     $k0, bev0_handler_targets
		ld	$k0, EXCV_TLB($k0)
		jr	$k0
		add     $k0, $0, EXCV_TLB
		.end bev0_tlb_handler_stub
		.ent bev1_tlb_handler_stub
bev1_tlb_handler_stub:
		dla     $k0, bev1_handler_targets
		ld	$k0, EXCV_TLB($k0)
		jr	$k0
		add     $k0, $0, EXCV_TLB
		.end bev1_tlb_handler_stub
		.ent bev0_xtlb_handler_stub
bev0_xtlb_handler_stub:	
		dla     $k0, bev0_handler_targets
		ld	$k0, EXCV_XTLB($k0)
		jr	$k0
		add     $k0, $0, EXCV_XTLB
		.end bev0_xtlb_handler_stub
		.ent bev1_xtlb_handler_stub
bev1_xtlb_handler_stub:
		dla     $k0, bev1_handler_targets
		ld	$k0, EXCV_XTLB($k0)
		jr	$k0
		add     $k0, $0, EXCV_XTLB
		.end bev1_xtlb_handler_stub
		.ent bev0_cache_handler_stub
bev0_cache_handler_stub:
		dla     $k0, bev0_handler_targets
		ld	$k0, EXCV_CACHE($k0)
		jr	$k0
		add     $k0, $0, EXCV_CACHE
		.end bev0_cache_handler_stub
		.ent bev1_cache_handler_stub
bev1_cache_handler_stub:
		dla     $k0, bev1_handler_targets
		ld	$k0, EXCV_CACHE($k0)
		jr	$k0
		add     $k0, $0, EXCV_CACHE
		.end bev1_cache_handler_stub
		.ent bev0_common_handler_stub
bev0_common_handler_stub:
		dla     $k0, bev0_handler_targets
		ld	$k0, EXCV_COMMON($k0)
		jr	$k0
		add     $k0, $0, EXCV_COMMON
		.end bev0_common_handler_stub
		.ent bev1_common_handler_stub
bev1_common_handler_stub:
		dla     $k0, bev1_handler_targets
		ld	$k0, EXCV_COMMON($k0)
		jr	$k0
		add     $k0, $0, EXCV_COMMON
		.end bev1_common_handler_stub

	
#
# Configure post-boot exception vectors by clearing the BEV bit in the CP0
# status register.  Stomps on t0 and t1.
#
		.text
		.global bev_clear
		.ent bev_clear
bev_clear:
		daddu	$sp, $sp, -32
		sd	$ra, 24($sp)
		sd	$fp, 16($sp)
		daddu	$fp, $sp, 32

		mfc0	$t0, $12
		dli	$t1, 1 << 22	# BEV bit
		nor	$t1, $t1
		and	$t0, $t0, $t1
		mtc0	$t0, $12

		ld	$fp, 16($sp)
		ld	$ra, 24($sp)
		daddu	$sp, $sp, 32
		jr	$ra
		nop			# branch-delay slot
		.end bev_clear
