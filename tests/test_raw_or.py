from bsim_utils import BaseBsimTestCase

class raw_or(BaseBsimTestCase):
    def or_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 or 0")

    def or_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "0 or 1")

    def or_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "1 or 0")

    def or_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0xffffffffffffffff, "1 or 1")
