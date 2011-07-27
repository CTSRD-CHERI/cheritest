#-
# Copyright (c) 2011 Jonathan D. Woodruff
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
# This test runs a loop of multiplying and dividing
# numbers with a seed from -10 to 10.  We just test
# that the final results are correct.
#

		.global test
test:		.ent test
		li	$s2,1
		li	$s1,-10
		li	$s6,1
loop:
		mul	$v0,$s2,$s1
		sw	$v0,0($sp)
		beqz	$s1, skip_div
		lw	$v0,0($sp)
		move	$s7,$v0
		div	$0,$v0,$s1
		teq	$s1,$0,0x7
		mflo	$v1
		move	$t8,$v1
skip_div:
		addiu	$s1,$s1,1
    move	$v1,$v0
		movz	$v1,$s6,$v0
		sw	$v1,0($sp)
		slti	$v0,$s1,10
		bnez	$v0, loop
		lw	$s2,0($sp)
end:
		jr	$ra
		nop			# branch-delay slot
		.end	test
