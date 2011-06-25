from bsim_utils import BaseBsimTestCase

class raw_ori(BaseBsimTestCase):
    def ori_zeros(self):
        self.assertRegisterEqual(self.MIPS.a0, 0x0000000000000000, "0 ori 0")

    def ori_left(self):
        self.assertRegisterEqual(self.MIPS.a1, 0x000000000000ffff, "0 ori 1")

    def ori_right(self):
        self.assertRegisterEqual(self.MIPS.a2, 0x000000000000ffff, "1 ori 0")

    def ori_both(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x000000000000ffff, "1 ori 1")
