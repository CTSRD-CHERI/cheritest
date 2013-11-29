#-
# Copyright (c) 2011 Robert N. M. Watson
# Copyright (c) 2013 Alexandre Joannou
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

idx10:      # need to be copied at 0x9800000000000140
            dli     $t0, 0x9800000000000280 # dest
            jr      $t0
idx10_end:  move    $t0, $zero    # branch-delay slot

idx20:      # need to be copied at 0x9800000000000280
            dli     $t0, 0x9800000000001080 # dest
            jr      $t0
idx20_end:  move    $t0, $zero    # branch-delay slot

idx132:     # need to be copied at 0x9800000000001080
            dli     $t0, 0x9800000000001c60 # dest
            jr      $t0
idx132_end: move    $t0, $zero    # branch-delay slot

idx227:     # need to be copied at 0x9800000000001c60
            dli     $t0, 0x9800000000000a60 # dest
            jr      $t0
idx227_end: move    $t0, $zero    # branch-delay slot

idx83:      # need to be copied at 0x9800000000000a60
            dli     $t0, 0x9800000000003e80 # dest
            jr      $t0
idx83_end:  move    $t0, $zero    # branch-delay slot

idx500:     # need to be copied at 0x9800000000003e80
            dli     $t0, 0x9800000000003280 # dest
            jr      $t0
idx500_end: move    $t0, $zero    # branch-delay slot

idx404:     # need to be copied at 0x9800000000003280
            dla     $t0, finish
            jr      $t0
idx404_end: move    $t0, $zero    # branch-delay slot

        .global test
test:   .ent    test
        daddu   $sp, $sp, -32
        sd      $ra, 24($sp)
        sd      $fp, 16($sp)
        daddu   $fp, $sp, 32

        dli     $a0, 0x9800000000000140 # dest
        dla     $a1, idx10              # src
        dli     $a2, idx10_end-idx10    # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000000280 # dest
        dla     $a1, idx20              # src
        dli     $a2, idx20_end-idx20    # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000001080 # dest
        dla     $a1, idx132             # src
        dli     $a2, idx132_end-idx132  # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000001c60 # dest
        dla     $a1, idx227             # src
        dli     $a2, idx227_end-idx227  # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000000a60 # dest
        dla     $a1, idx83              # src
        dli     $a2, idx83_end-idx83    # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000003e80 # dest
        dla     $a1, idx500             # src
        dli     $a2, idx500_end-idx500  # len
        jal     memcpy
        nop

        dli     $a0, 0x9800000000003280 # dest
        dla     $a1, idx404             # src
        dli     $a2, idx404_end-idx404  # len
        jal     memcpy
        nop

        #start fetching instruction cache lines at different indexes
        dli     $t0, 0x9800000000000140
        jr      $t0
        move    $t0, $zero    # branch-delay slot

finish:

        # invalidate some of the cache lines
        dli     $t0, 0x9800000000000140 # idx10
        cache   0x0, 0($t0)
        dli     $t0, 0x9800000000001080 # idx132
        cache   0x0, 0($t0)
        dli     $t0, 0x9800000000003280 # idx404
        cache   0x0, 0($t0)
        nop
        nop
        nop
        nop

        # Dump the ICache tags in the simulator
        mtc0    $v0, $26, 1
        nop
        nop

        ld      $fp, 16($sp)
        ld      $ra, 24($sp)
        daddu   $sp, $sp, 32
        jr      $ra
        nop            # branch-delay slot
        .end    test
