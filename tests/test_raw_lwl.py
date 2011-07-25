from bsim_utils import BaseBsimTestCase

class raw_lwl(BaseBsimTestCase):
	def test_offset_zero(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffedcba98, "LWL with zero offset failed")

	def test_offset_one(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffffdcba9800, "LWL with one offset failed")

	def test_offset_two(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xffffffffba980000, "LWL with two offset failed")

	def test_offset_three(self):
		self.assertRegisterEqual(self.MIPS.a4, 0xffffffff98000000, "LWL with three offset failed")

	def test_offset_four(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x0000000076543210, "LWL with four offset (skip word) failed")
