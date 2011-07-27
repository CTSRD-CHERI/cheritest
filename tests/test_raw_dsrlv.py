from bsim_utils import BaseBsimTestCase

class raw_dsrlv(BaseBsimTestCase):
        def test_a1(self):
		'''Test a DSRLV of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "Shift of zero failed")

	def test_a2(self):
		'''Test a DSRLV of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0x7f6e5d4c3b2a1908, "Shift of one failed")

	def test_a3(self):
		'''Test a DSRLV of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0x0000fedcba987654, "Shift of sixteen failed")

	def test_a4(self):
		'''Test a DSRLV of 31(max)'''
		self.assertRegisterEqual(self.MIPS.a4, 0x00000001fdb97530, "Shift of thirty-one (max) failed")
