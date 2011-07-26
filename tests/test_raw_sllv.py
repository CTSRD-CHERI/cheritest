from bsim_utils import BaseBsimTestCase

class raw_sllv(BaseBsimTestCase):
        def test_a1(self):
		'''Test a SLLV of zero'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfedcba9876543210, "Initial value from dli failed to load")
		self.assertRegisterEqual(self.MIPS.a1, 0x0000000076543210, "Shift of zero resulting in truncation failed")

	def test_a2(self):
		'''Test a SLLV of one'''
		self.assertRegisterEqual(self.MIPS.a2, 0xffffffffeca86420, "Shift of one resulting in sign extension failed")

	def test_a3(self):
		'''Test a SLLV of sixteen'''
		self.assertRegisterEqual(self.MIPS.a3, 0x0000000032100000, "Shift of sixteen failed")

	def test_a4(self):
		'''Test a SLLV of 31(max)'''
		self.assertRegisterEqual(self.MIPS.a4, 0x0000000000000000, "Shift of thirty-one (max) failed")
