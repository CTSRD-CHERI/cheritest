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
# This test exercises movz and movn in true and false
# cases for each.  They take operands fed from preceding
# loads and feed into stores.  This case failed in compiled
# code due to movz and movn being a special case for
# pipeline forwarding.
#

		.global test
test:		.ent test
movz_false:
    li	$a0,1
    li	$a1,-1
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movz	$v1,$a0,$v0
    sw	$v1,0($sp)
    lw	$s0,0($sp)
movz_true:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movz	$v1,$a0,$zero
    sw	$v1,0($sp)
    lw	$s1,0($sp)
movn_false:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movn	$v1,$a0,$zero
    sw	$v1,0($sp)
    lw	$s2,0($sp)
movn_true:
    sw	$a1,0($sp)
    lw	$v0,0($sp)
    lw	$v1,0($sp)
    movn	$v1,$a0,$v1
    sw	$v1,0($sp)
    lw	$s3,0($sp)
end:
		jr	$ra
		nop			# branch-delay slot
		.end	test
