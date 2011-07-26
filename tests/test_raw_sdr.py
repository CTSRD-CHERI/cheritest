from bsim_utils import BaseBsimTestCase

class raw_sdr(BaseBsimTestCase):
	def test_a1(self):
		self.assertRegisterEqual(self.MIPS.a1, 0x1000000000000000, "SDR with zero offset failed")

	def test_a2(self):
		self.assertRegisterEqual(self.MIPS.a2, 0x3210000000000000, "SDR with one byte offset failed")

	def test_a3(self):
		self.assertRegisterEqual(self.MIPS.a3, 0x5432100000000000, "SDR with two byte offset failed")

	def test_a4(self):
		self.assertRegisterEqual(self.MIPS.a4, 0x7654321000000000, "SDR with three byte offset failed")

	def test_a5(self):
		self.assertRegisterEqual(self.MIPS.a5, 0x9876543210000000, "SDR with four byte offset failed")

	def test_a6(self):
		self.assertRegisterEqual(self.MIPS.a6, 0xba98765432100000, "SDR with five byte offset failed")

	def test_a7(self):
		self.assertRegisterEqual(self.MIPS.a7, 0xdcba987654321000, "SDR with six byte offset failed")

	def test_t0(self):
		self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210, "SDR with seven byte offset failed")

	def test_t1(self):
		self.assertRegisterEqual(self.MIPS.t1, 0x1000000000000000, "SDR with full doubleword offset failed")
