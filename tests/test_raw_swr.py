from bsim_utils import BaseBsimTestCase

class raw_swr(BaseBsimTestCase):
	def test_a0(self):
		'''Test SWR with zero offset'''
		self.assertRegisterEqual(self.MIPS.a0, 0x9800000000000000, "SWR with zero offset failed")

	def test_a1(self):
		'''Test SWR with full word offset'''
		self.assertRegisterEqual(self.MIPS.a1, 0x9800000098000000, "SWR with full word offset failed")

	def test_a2(self):
		'''Test SWR with half word offset'''
		self.assertRegisterEqual(self.MIPS.a2, 0xdcba980098000000, "SWR with half word offset failed")

	def test_a3(self):
		'''Test SWR with one byte offset'''
		self.assertRegisterEqual(self.MIPS.a3, 0xdcba9800fedcba98, "SWR with three byte offset failed")

	def test_a4(self):
		'''Test SWR with three byte offset'''
		self.assertRegisterEqual(self.MIPS.a4, 0xdcba9800ba98ba98, "SWR with one byte offset failed")
