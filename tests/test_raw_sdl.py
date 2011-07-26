from bsim_utils import BaseBsimTestCase

class raw_sdl(BaseBsimTestCase):
	def test_a1(self):
		self.assertRegisterEqual(self.MIPS.a1, 0xfedcba9876543210, "SDL with zero offset failed")

	def test_a2(self):
		self.assertRegisterEqual(self.MIPS.a2, 0xfefedcba98765432, "SDL with one byte offset failed")

	def test_a3(self):
		self.assertRegisterEqual(self.MIPS.a3, 0xfefefedcba987654, "SDL with two byte offset failed")

	def test_a4(self):
		self.assertRegisterEqual(self.MIPS.a4, 0xfefefefedcba9876, "SDL with three byte offset failed")

	def test_a5(self):
		self.assertRegisterEqual(self.MIPS.a5, 0xfefefefefedcba98, "SDL with four byte offset failed")

	def test_a6(self):
		self.assertRegisterEqual(self.MIPS.a6, 0xfefefefefefedcba, "SDL with five byte offset failed")

	def test_a7(self):
		self.assertRegisterEqual(self.MIPS.a7, 0xfefefefefefefedc, "SDL with six byte offset failed")

	def test_t0(self):
		self.assertRegisterEqual(self.MIPS.t0, 0xfefefefefefefefe, "SDL with seven byte offset failed")

	def test_t1(self):
		self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210, "SDL with full doubleword offset failed")
