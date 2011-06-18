from bsim_utils import BaseBsimTestCase

class raw_load_delay_store(BaseBsimTestCase):
    def test_0nop(self):
        self.assertRegisterEqual(self.MIPS.t0, 0xfedcba9876543210, "load to store with zero NOPs failed")

    def test_1nop(self):
        self.assertRegisterEqual(self.MIPS.t1, 0xfedcba9876543210, "load to store with one NOP failed")

    def test_2nop(self):
        self.assertRegisterEqual(self.MIPS.t2, 0xfedcba9876543210, "load to store with two NOPs failed")

    def test_3nop(self):
        self.assertRegisterEqual(self.MIPS.t3, 0xfedcba9876543210, "load to store with three NOP failed")
