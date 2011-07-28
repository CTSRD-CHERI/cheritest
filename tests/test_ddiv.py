from bsim_utils import BaseBsimTestCase

class test_ddiv(BaseBsimTestCase):
	def test_pos_pos(self):
		'''Test of positive number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a0, 0xdebc9a78563412, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a1, 0xf, "Division failed")

	def test_neg_neg(self):
		'''Test of negative number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a2, 0xff21436587a9cbee, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a3, 0xf, "Division failed")

	def test_neg_pos(self):
		'''Test of negative number divided by positive number'''
		self.assertRegisterEqual(self.MIPS.a4, 0xff21436587a9cbee, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a5, 0xfffffffffffffff1, "Division failed")

	def test_pos_neg(self):
		'''Test of positive number divided by negative number'''
		self.assertRegisterEqual(self.MIPS.a6, 0xdebc9a78563412, "Modulo failed")
		self.assertRegisterEqual(self.MIPS.a7, 0xfffffffffffffff1, "Division failed")
