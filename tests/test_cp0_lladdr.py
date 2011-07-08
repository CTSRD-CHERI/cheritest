from bsim_utils import BaseBsimTestCase

class test_cp0_lladdr(BaseBsimTestCase):
    def test_lladdr_reset(self):
	'''Test that CP0 lladdr is 0 on CPU reset'''
	self.assertRegisterEqual(self.MIPS.a0, 0, "CP0 lladdr non-zero on reset");

    def test_lladdr_after_ll(self):
	'''Test that lladdr is set correctly after load linked'''
	self.assertRegisterEqual(self.MIPS.a1, self.MIPS.s0, "lladdr after ll incorrect")

    def test_lladdr_after_sc(self):
	'''Test that lladdr is still set correctly after store conditional'''
	self.assertRegisterEqual(self.MIPS.a2, self.MIPS.s0, "lladdr after sc incorrect")

    def test_lladdr_after_lld(self):
	'''Test that lladdr is set correctly after load linked double word'''
	self.assertRegisterEqual(self.MIPS.a3, self.MIPS.s3, "lladdr after lld incorrect")

    def test_lladdr_after_scd(self):
	'''Test that lladdr is still set correctly after store conditional double word'''
	self.assertRegisterEqual(self.MIPS.a4, self.MIPS.s3, "lladdr after scd incorrect")

    def test_lladdr_double_ll(self):
	'''Test that if a second ll occurs before sc, sc will see the second lladdr'''
	self.assertRegisterEqual(self.MIPS.a5, self.MIPS.s1, "lladdr after double ll incorrect")

    def test_lladdr_double_lld(self):
	'''Test that if a second lld occurs before scd, scd will see the second lladdr'''
	self.assertRegisterEqual(self.MIPS.a6, self.MIPS.s4, "lladdr after double ll incorrect")

    def test_lladdr_ll_interrupted(self):
	'''Test that if an ll is followed by an sw that clears LLbit, lladdr is still correct'''
	self.assertRegisterEqual(self.MIPS.a7, self.MIPS.s2, "lladdr after interrupted ll incorrect")

    def test_lladdr_lld_interrupted(self):
	'''Test that if an lld is followed by an sd that clears LLbit, lladdr is still correct'''
	self.assertRegisterEqual(self.MIPS.s6, self.MIPS.s5, "lladdr after interrupted lld incorrect")
