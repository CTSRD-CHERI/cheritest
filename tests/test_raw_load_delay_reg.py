from bsim_utils import BaseBsimTestCase

class raw_load_delay_reg(BaseBsimTestCase):
    def test_t0(self):
        self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210, "load to reg with zero NOPs failed")

    def test_t1(self):
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210, "load to reg with one NOP failed")

    def test_t2(self):
        self.assertRegisterEqual(self.MIPS.t2, 0xfedcba9876543210, "load to reg with two NOPs failed")

    def test_t3(self):
        self.assertRegisterEqual(self.MIPS.t3, 0xfedcba9876543210, "load to reg with three NOP failed")
