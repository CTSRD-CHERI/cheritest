from bsim_utils import BaseBsimTestCase

class raw_ldl(BaseBsimTestCase):
	def test_full_word(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "LDL with zero offset failed")
		self.assertRegisterEqual(self.MIPS.a4, 0xfedcba9876543210, "LDL with zero offset failed")

	def test_half_word(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffff00000000, "LDL with four byte offset failed")
		self.assertRegisterEqual(self.MIPS.a5, 0x7654321000000000, "LDL with four byte offset failed")

	def test_skip_word(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xfedcba9876543210, "LDL with word offset failed")
		self.assertRegisterEqual(self.MIPS.a6, 0, "LDL with word offset failed")
