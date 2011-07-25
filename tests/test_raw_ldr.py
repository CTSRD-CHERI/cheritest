from bsim_utils import BaseBsimTestCase

class raw_ldr(BaseBsimTestCase):
	def test_offset_zero(self):
		self.assertRegisterEqual(self.MIPS.a1, 0x00000000000000fe, "LDR with zero offset failed")

	def test_offset_one(self):
		self.assertRegisterEqual(self.MIPS.a2, 0x000000000000fedc, "LDR with one offset failed")

	def test_offset_two(self):
		self.assertRegisterEqual(self.MIPS.a3, 0x0000000000fedcba, "LDR with two offset failed")

	def test_offset_three(self):
		self.assertRegisterEqual(self.MIPS.a4, 0x00000000fedcba98, "LDR with three offset failed")

	def test_offset_four(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x000000fedcba9876, "LDR with four offset failed")

	def test_offset_five(self):
		self.assertRegisterEqual(self.MIPS.a6, 0x0000fedcba987654, "LDR with five offset failed")

	def test_offset_six(self):
		self.assertRegisterEqual(self.MIPS.a7, 0x00fedcba98765432, "LDR with six offset failed")

	def test_offset_seven(self):
		self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210, "LDR with seven offset failed")

	def test_offset_eight(self):
		self.assertRegisterEqual(self.MIPS.t1, 0, "LDR with eight offset (skip double word) failed")
