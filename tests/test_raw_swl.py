from bsim_utils import BaseBsimTestCase

class raw_swl(BaseBsimTestCase):
	def test_a0(self):
		'''Test SWL with zero offset'''
		self.assertRegisterEqual(self.MIPS.a0, 0xfffffffffedcba98, "SWL with zero offset failed")

	def test_a1(self):
		'''Test SWL with full word offset'''
		self.assertRegisterEqual(self.MIPS.a1, 0xfffffffffedcba98, "SWL with full word offset failed")

	def test_a2(self):
		'''Test SWL with half word offset'''
		self.assertRegisterEqual(self.MIPS.a2, 0xfffffffffedc0000, "SWL with half word offset failed")

	def test_a3(self):
		'''Test SWL with one byte offset'''
		self.assertRegisterEqual(self.MIPS.a3, 0xfffffffffe000000, "SWL with one byte offset failed")

	def test_a4(self):
		'''Test SWL with three byte offset'''
		self.assertRegisterEqual(self.MIPS.a4, 0xfffffffffe0000fe, "SWL with three byte offset failed")
