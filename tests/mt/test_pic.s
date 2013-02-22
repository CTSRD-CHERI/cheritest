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
# page in the xuseg segment and attempts a store via it.

.set mips64
.set noreorder
.set nobopt
.set noat

.global test
test:   .ent    test
        dla     $a0, 0x900000007f804000  # PIC_BASE
        dla     $t0, 0x80000004          # enable irq 2, forward to IP4
        sd      $t0, 16($a0)
        dadd    $a1, $a0, 0x2000         # PIC_IP_READ_BASE        
        li      $t0, 6
        sd      $t0, 128($a1)            # set irq 2 and 1
        ld      $a2, 0($a1)              # read irq pending
        dmfc0   $a3, $13                 # read cause reg
        sd      $t0, 256($a1)            # clear irq 2
        ld      $a4, 0($a1)              # read irq pending
	jr      $ra
	nop
.end    test
