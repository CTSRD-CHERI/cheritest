from bsim_utils import BaseBsimTestCase

class test_ddivu(BaseBsimTestCase):
	def test_pos_pos(self):
		'''Test of positive number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a0, 0xdebc9a78563412, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a1, 0xf, "Division failed")

	def test_neg_neg(self):
		'''Test of negative number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a2, 0xf0123456789abcdf, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a3, 0, "Division failed")

	def test_neg_pos(self):
		'''Test of negative number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0x22446688aaccf0, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a5, 0xef, "Division failed")

	def test_pos_neg(self):
		'''Test of positive number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 0xfedcba987654321, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a7, 0, "Division failed")
