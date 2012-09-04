#-
# Copyright (c) 2011 Steven J. Murdoch
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

		.global start
start:
                # get fields of a capability
		cgetperm $a1,  $c2
		cgettype $a1,  $c2
		cgetbase $a1,  $c2
		cgetlen  $a1,  $c2
                cgettag  $a1,  $c2
                cgetunsealed $a1, $c2

                # set the fields of a capability
		candperm $c1,  $c2, $a3
		csettype $c1,  $c2, $a3
		cincbase $c1,  $c2, $a3
		csetlen  $c1,  $c2, $a3
                ccleartag $c1

		cmove    $c1,  $c2

                # store/load capability
		csc      $c1,  $a3($c2)
		clc      $c1,  $a3($c2)

                # store/load capability (old instruction)
		cscr      $c1,  $a3($c2)
		clcr      $c1,  $a3($c2)

                # load via capability
                clb      $a1,  $a3($c2)
                clh      $a1,  $a3($c2)
                clw      $a1,  $a3($c2)
                cld      $a1,  $a3($c2)

                # load via capability (old instruction)
		clbi     $a1,  0x7($c2)
		clhi     $a1,  0xf($c2)
		clwi     $a1,  0xff($c2)
		cldi     $a1,  0x7ff($c2)
		clbr     $a1,  $a3($c2)
		clhr     $a1,  $a3($c2)
		clwr     $a1,  $a3($c2)
		cldr     $a1,  $a3($c2)
 
                # store via capability
                clb     $a1,  $a3($c2)
                clh      $a1,  $a3($c2)
                clw      $a1,  $a3($c2)
                cld      $a1,  $a3($c2)

                # store via capability (old instruction)
		csbi     $a1,  0x7($c2)
		cshi     $a1,  0xf($c2)
		cswi     $a1,  0xff($c2)
		csdi     $a1,  0x7ff($c2)
		csbr     $a1,  $a3($c2)
		cshr     $a1,  $a3($c2)
		cswr     $a1,  $a3($c2)
		csdr     $a1,  $a3($c2)

		cjr      $3($c1)
		cjalr    $3($c1)
		csealcode $c1,  $c2
		csealdata $c1,  $c2, $c3
		cunseal  $c1,  $c2, $c3
		ccall    $c1,  $c2
		creturn

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $v0, $23
end:
		b end
		nop
