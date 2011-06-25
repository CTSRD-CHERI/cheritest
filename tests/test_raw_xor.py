from bsim_utils import BaseBsimTestCase

class raw_xor(BaseBsimTestCase):
    def xor_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 xor 0")

    def xor_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0xffffffffffffffff, "0 xor 1")

    def xor_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffffffff, "1 xor 0")

    def xor_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x0000000000000000, "1 xor 1")
