from bsim_utils import BaseBsimTestCase

class raw_sra(BaseBsimTestCase):
        def test_a1(self):
		'''Test a SRA of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0x0000000076543210, "Shift of zero resulting in truncation failed")

	def test_a2(self):
		'''Test a SRA of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0x000000003b2a1908, "Shift of one failed")

	def test_a3(self):
		'''Test a SRA of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0x0000000000007654, "Shift of sixteen failed")

	def test_a4(self):
		'''Test a SRA of 31(max)'''
		self.assertRegisterEqual(self.MIPS.a4, 0x0000000000000000, "Shift of thirty-one (max) failed")

	def test_a6(self):
		'''Test a SRA of zero with sign extension'''
		self.assertRegisterEqual(self.MIPS.a5, 0x00000000ffffffff, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a6, 0xffffffffffffffff, "Shift of zero with sign extension failed")

	def test_a7(self):
		'''Test a SRA of one with sign extension'''
		self.assertRegisterEqual(self.MIPS.a7, 0xffffffffffffffff, "Shift of one with sign extension failed")

	def test_t0(self):
		'''Test a SRA of sixteen with sign extension'''
		self.assertRegisterEqual(self.MIPS.t0, 0xffffffffffffffff, "Shift of sixteen with sign extension failed")
