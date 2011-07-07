from bsim_utils import BaseBsimTestCase

class test_llsc(BaseBsimTestCase):

    def test_ll_sc_success(self):
	'''That an uninterrupted ll+sc succeeds'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Uninterrupted ll+sc failed")

    def test_ll_sc_value(self):
	'''That an uninterrupted ll+sc stored the right value'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffff, "Uninterrupted ll+sc stored wrong value")

    def test_ll_ld_sc_success(self):
	'''That an uninterrupted ll+ld+sc succeeds'''
	self.assertRegisterEqual(self.MIPS.a2, 1, "Uninterrupted ll+ld+sc failed")

    def test_ll_add_sc_success(self):
	'''That an uninterrupted ll+add+sc succeeds'''
	self.assertRegisterEqual(self.MIPS.a3, 1, "Uninterrupted ll+add+sc failed")

    def test_ll_add_sc_value(self):
	'''That an uninterrupted ll+add+sc stored the right value'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "Uninterrupted ll+add+sc stored wrong value")

    def test_ll_sw_sc_failure(self):
	'''That an ll+sw+sc spanning fails'''
	self.assertRegisterEqual(self.MIPS.a5, 0, "Interrupted ll+sw+sc succeeded")

    def test_ll_sw_sc_value(self):
	'''That an ll+sc spanning a store to the line does not store'''
	self.assertRegisterNotEqual(self.MIPS.a6, 1, "Interrupted ll+sw+sc stored value")

    def test_ll_tnei_sc_failure(self):
	'''That an ll+sc spanning a trap fails'''
	self.assertRegisterEqual(self.MIPS.a7, 0, "Interrupted ll+tnei+sc succeeded")
