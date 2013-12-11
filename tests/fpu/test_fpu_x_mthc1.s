#-
# Copyright (c) 2013 Michael Roe
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

.global test
.ent test
test:		
	daddu 	$sp, $sp, -32
	sd	$ra, 24($sp)
	sd	$fp, 16($sp)
	daddu	$fp, $sp, 32

	#
	# Set up exception handler
	#

	jal	bev_clear
	nop
	dla	$a0, bev0_handler
	jal	bev0_handler_install
	nop

	dli $a0, 0
	dli $a2, 0

	mfc0 $t0, $12
        li $t1, 1 << 29		# Enable CP1
        or $t0, $t0, $t1    
	mtc0 $t0, $12 
        nop
        nop
        nop

	lui	$t0, 0x7654
	ori	$t0, 0x3210
	dmtc1	$t0, $f0

	lui	$t0, 0xfedc
	ori	$t0, 0xba98

	.set push
	.set mips32r2
	# If mthc1 is not implemented, this should raise an exception
	mthc1	$t0, $f0
	.set pop

	dmfc1	$a0, $f0

	ld	$fp, 16($sp)
	ld	$ra, 24($sp)
	daddu	$sp, $sp, 32
	jr	$ra
	nop
.end test

.ent bev0_handler
bev0_handler:
	li	$a2, 1

	mfc0	$a3, $13
	srl	$a3, $a3, 2
	andi	$a3, $a3, 0x1f	# ExcCode

	dmfc0	$a5, $14	# EPC
	daddiu	$k0, $a5, 4	# EPC += 4 to bump PC forward on ERET
	dmtc0	$k0, $14
	nop
	nop
	nop
	nop
	eret
.end bev0_handler

