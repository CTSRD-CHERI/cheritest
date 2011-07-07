from bsim_utils import BaseBsimTestCase

class test_lldscd(BaseBsimTestCase):

    def test_lld_scd_success(self):
	'''That an uninterrupted lld+scd succeeds'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Uninterrupted lld+scd failed")

    def test_lld_scd_value(self):
	'''That an uninterrupted lld+scd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "Uninterrupted lld+scd stored wrong value")

    def test_lld_ld_scd_success(self):
	'''That an uninterrupted lld+ld+scd succeeds'''
	self.assertRegisterEqual(self.MIPS.a2, 1, "Uninterrupted lld+ld+scd failed")

    def test_lld_add_scd_success(self):
	'''That an uninterrupted lld+add+scd succeeds'''
	self.assertRegisterEqual(self.MIPS.a3, 1, "Uninterrupted lld+add+scd failed")

    def test_lld_add_scd_value(self):
	'''That an uninterrupted lld+add+scd stored the right value'''
	self.assertRegisterEqual(self.MIPS.a4, 0, "Uninterrupted lld+add+scd stored wrong value")

    def test_lld_sd_scd_failure(self):
	'''That an lld+sd+scd spanning fails'''
	self.assertRegisterEqual(self.MIPS.t0, 0, "Interrupted lld+sd+scd succeeded")

    def test_lld_sd_scd_value(self):
	'''That an lld+scd spanning a store to the line does not store'''
	self.assertRegisterNotEqual(self.MIPS.a6, 1, "Interrupted lld+sd+scd stored value")

    def test_lld_tnei_scd_failure(self):
	'''That an lld+scd spanning a trap fails'''
	self.assertRegisterEqual(self.MIPS.a7, 0, "Interrupted lld+tnei+scd succeeded")
