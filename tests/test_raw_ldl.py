from bsim_utils import BaseBsimTestCase

class raw_ldl(BaseBsimTestCase):
	def test_offset_zero(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "LDL with zero offset failed")

	def test_offset_one(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xdcba987654321000, "LDL with one offset failed")

	def test_offset_two(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xba98765432100000, "LDL with two offset failed")

	def test_offset_three(self):
		self.assertRegisterEqual(self.MIPS.a4, 0x9876543210000000, "LDL with three offset failed")

	def test_offset_four(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x7654321000000000, "LDL with four offset failed")

	def test_offset_five(self):
		self.assertRegisterEqual(self.MIPS.a6, 0x5432100000000000, "LDL with five offset failed")

	def test_offset_six(self):
		self.assertRegisterEqual(self.MIPS.a7, 0x3210000000000000, "LDL with six offset failed")

	def test_offset_seven(self):
		self.assertRegisterEqual(self.MIPS.t0, 0x1000000000000000, "LDL with seven offset failed")

	def test_offset_eight(self):
		self.assertRegisterEqual(self.MIPS.t1, 0x0000000000000000, "LDL with eight offset (skip double word) failed")
