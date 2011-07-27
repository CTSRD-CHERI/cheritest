from bsim_utils import BaseBsimTestCase

class test_div(BaseBsimTestCase):
	def test_pos_pos(self):
		'''Test of positive number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a0, 3, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a1, 5, "Division failed")

	def test_neg_neg(self):
		'''Test of negative number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a2, 0xfffffffffffffffd, "Modulo with sign extension failed")
		self.assertRegisterEqual(self.MIPS.a3, 5, "Division failed")

	def test_neg_pos(self):
		'''Test of negative number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0xfffffffffffffffd, "Modulo with sign extension failed")
		self.assertRegisterEqual(self.MIPS.a5, 0xfffffffffffffffb, "Division with sign extension failed")

	def test_pos_neg(self):
		'''Test of positive number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 3, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a7, 0xfffffffffffffffb, "Division with sign extension failed")
