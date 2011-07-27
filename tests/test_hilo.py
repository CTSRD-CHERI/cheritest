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
from bsim_utils import BaseBsimTestCase

class test_hilo(BaseBsimTestCase):
    def test_hilo_set_hi(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xe624379d7daf6318, "HI not preserved across set/get")

    def test_hilo_set_lo(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x608467ffc8a78552, "LO not preserved across set/get")

    def test_hilo_dmult(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x0469266d00323390, "HI incorrect after dmult")
        self.assertRegisterEqual(self.MIPS.a5, 0xe2492cdfae99444a, "LO incorrect after dmult")

    def test_hilo_ddiv(self):
        self.assertRegisterEqual(self.MIPS.a6, 0x2aa7f6bfd4716e30, "HI incorrect after ddiv")
        self.assertRegisterEqual(self.MIPS.a7, 0x1, "LO incorrect after ddiv")
