from bsim_utils import BaseBsimTestCase

class raw_hilo(BaseBsimTestCase):
    def test_init_hi(self):
        self.assertRegisterEqual(self.MIPS.a0, 0, "HI non-zero on reset")

    def test_init_lo(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "LO non-zero on reset")
