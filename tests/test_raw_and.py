from bsim_utils import BaseBsimTestCase

class raw_and(BaseBsimTestCase):
    def and_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 and 0")

    def and_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x0000000000000000, "0 and 1")

    def and_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0x0000000000000000, "1 and 0")

    def and_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0xffffffffffffffff, "1 and 1")
