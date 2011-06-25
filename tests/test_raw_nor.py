from bsim_utils import BaseBsimTestCase

class raw_nor(BaseBsimTestCase):
    def nor_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0xffffffffffffffff, "0 nor 0")

    def nor_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x0000000000000000, "0 nor 1")

    def nor_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0x0000000000000000, "1 nor 0")

    def nor_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x0000000000000000, "1 nor 1")
