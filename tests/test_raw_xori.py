from bsim_utils import BaseBsimTestCase

class raw_xori(BaseBsimTestCase):
    def xori_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 xori 0")

    def xori_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x000000000000ffff, "0 xori 1")

    def xori_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffff0000, "1 xori 0")

    def xori_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x0000000000000000, "1 xori 1")
