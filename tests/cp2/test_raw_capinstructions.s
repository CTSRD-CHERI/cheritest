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

start:
		cscr    $c1,  $c2, $a3
		cjr     $c1,  $3
		cjalr   $c1,  $3
		ccall   $c1,  $c2
		creturn
		cgetbase $a1,  $c2
		cgetleng $a1,  $c2
		cgetperm $a1,  $c2
		cgettype $a1,  $c2
		csettype $c1,  $c2, $a3
		cincbase $c1,  $c2, $a3
		cdecleng $c1,  $c2, $a3
		candperm $c1,  $c2, $a3
		clcr     $c1,  $c2, $a3
		csealcode $c1,  $c2
		csealdata $c1,  $c2, $c3
		cunseal  $c1,  $c2, $c3
		clb      $a1,  $c2, 0x0
		clw      $a1,  $c2, 0xff
		cld      $a1,  $c2, 0x7ff
		csb      $a1,  $c2, 0x0
		csw      $a1,  $c2, 0xff
		csd      $a1,  $c2, 0x7ff
		clbr     $a1,  $c2, $a3
		clwr     $a1,  $c2, $a3
		cldr     $a1,  $c2, $a3
		csbr     $a1,  $c2, $a3
		cswr     $a1,  $c2, $a3
		csdr     $a1,  $c2, $a3

		# Dump registers in the simulator
		mtc0 $v0, $26
		nop
		nop

		# Terminate the simulator
		mtc0 $v0, $23
end:
		b end
