from bsim_utils import BaseBsimTestCase

class raw_lwr(BaseBsimTestCase):
	def test_offset_zero(self):
		self.assertRegisterEqual(self.MIPS.a1, 0x00000000000000fe, "LWR with zero offset failed")

	def test_offset_one(self):
		self.assertRegisterEqual(self.MIPS.a2, 0x000000000000fedc, "LWR with one offset failed")

	def test_offset_two(self):
		self.assertRegisterEqual(self.MIPS.a3, 0x0000000000fedcba, "LWR with two offset failed")

	def test_offset_three(self):
		self.assertRegisterEqual(self.MIPS.a4, 0xfffffffffedcba98, "LWR with three offset failed")

	def test_offset_four(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x0000000000000076, "LWR with four offset (skip word) failed")
