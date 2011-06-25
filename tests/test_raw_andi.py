from bsim_utils import BaseBsimTestCase

class raw_andi(BaseBsimTestCase):
    def andi_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 andi 0")

    def andi_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x0000000000000000, "0 andi 1")

    def andi_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0x0000000000000000, "1 andi 0")

    def andi_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x000000000000ffff, "1 andi 1")
