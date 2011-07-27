from bsim_utils import BaseBsimTestCase

class raw_dsrl32(BaseBsimTestCase):
        def test_a1(self):
		'''Test a DSRL32 of zero, effective 32'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0x00000000fedcba98, "Shift of 32 failed")

	def test_a2(self):
		'''Test a DSRL32 of one, effective 33'''
		self.assertRegisterEqual(self.MIPS.a2, 0x000000007f6e5d4c, "Shift of 33 failed")

	def test_a3(self):
		'''Test a DSRL32 of sixteen, effective 48'''
		self.assertRegisterEqual(self.MIPS.a3, 0x000000000000fedc, "Shift of 48 failed")

	def test_a4(self):
		'''Test a DSRL32 of 31(max), effective 63'''
		self.assertRegisterEqual(self.MIPS.a4, 0x0000000000000001, "Shift of 63 (max) failed")
