from bsim_utils import BaseBsimTestCase

class raw_dsra32(BaseBsimTestCase):
        def test_a1(self):
		'''Test a DSRA32 of zero, effective 32'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffedcba98, "Shift of 32 failed")

	def test_a2(self):
		'''Test a DSRA32 of one, effective 33'''
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffffff6e5d4c, "Shift of 33 failed")

	def test_a3(self):
		'''Test a DSRA32 of sixteen, effective 48'''
		self.assertRegisterEqual(self.MIPS.a3, 0xfffffffffffffedc, "Shift of 48 failed")

	def test_a4(self):
		'''Test a DSRA32 of 31(max), effective 63'''
		self.assertRegisterEqual(self.MIPS.a4, 0xffffffffffffffff, "Shift of 63 (max) failed")
