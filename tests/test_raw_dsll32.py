from bsim_utils import BaseBsimTestCase

class raw_dsll32(BaseBsimTestCase):
        def test_a1(self):
		'''Test a DSLL32 of zero, effective 32'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0x7654321000000000, "Shift of thirty-two failed")

	def test_a2(self):
		'''Test a DSLL32 of one, effective 33'''
		self.assertRegisterEqual(self.MIPS.a2, 0xeca8642000000000, "Shift of thirty-three failed")

	def test_a3(self):
		'''Test a DSLL32 of sixteen, effective 48'''
		self.assertRegisterEqual(self.MIPS.a3, 0x3210000000000000, "Shift of fourty-eight failed")

	def test_a4(self):
		'''Test a DSLL32 of 31(max), effective 63'''
		self.assertRegisterEqual(self.MIPS.a4, 0x0000000000000000, "Shift of sixty-three (max) failed")
