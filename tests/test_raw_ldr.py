from bsim_utils import BaseBsimTestCase

class raw_ldr(BaseBsimTestCase):
	def test_full_word(self):
		self.assertRegisterEqual(self.MIPS.a1, 0x00000000000000ff, "LDL with zero offset failed")
		self.assertRegisterEqual(self.MIPS.a4, 0x00000000000000fe, "LDL with zero offset failed")

	def test_half_word(self):
		self.assertRegisterEqual(self.MIPS.a2, 0x000000ffffffffff, "LDL with four byte offset failed")
		self.assertRegisterEqual(self.MIPS.a5, 0x000000fedcba9876, "LDL with four byte offset failed")

	def test_skip_word(self):
		self.assertRegisterEqual(self.MIPS.a3, 0x00000000000000fe, "LDL with word offset failed")
		self.assertRegisterEqual(self.MIPS.a6, 0, "LDL with word offset failed")
