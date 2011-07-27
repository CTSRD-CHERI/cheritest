from bsim_utils import BaseBsimTestCase

class raw_dsllv(BaseBsimTestCase):
        def test_a1(self):
		'''Test a DSLLV of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "Shift of zero failed")

	def test_a2(self):
		'''Test a DSLLV of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0xfdb97530eca86420, "Shift of one failed")

	def test_a3(self):
		'''Test a DSLLV of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0xba98765432100000, "Shift of sixteen failed")

	def test_a4(self):
		'''Test a DSLLV of 32'''
		self.assertRegisterEqual(self.MIPS.a4, 0x7654321000000000, "Shift of thirty-two failed")

	def test_a5(self):
		'''Test a DSLLV of 43'''
		self.assertRegisterEqual(self.MIPS.a5, 0xa190800000000000, "Shift of fourty-three failed")

	def test_a6(self):
		'''Test a DSLLV pf 63(max)'''
		self.assertRegisterEqual(self.MIPS.a6, 0x0000000000000000, "Shift of sixty-three failed")
