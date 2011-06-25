from bsim_utils import BaseBsimTestCase

class raw_jump_and_link(BaseBsimTestCase):
    def test_jal(self):
        self.assertRegisterEqual(self.MIPS.t0, 1, "instruction before jal missed")

    def test_t1(self):
        self.assertRegisterEqual(self.MIPS.t1, 2, "insruction in branch-delay slot missed")

    def test_t2(self):
        self.assertRegisterEqual(self.MIPS.t2, 0, "jump didn't happen")

    def test_t3(self):
        self.assertRegisterEqual(self.MIPS.t3, 4, "instruction at jump target didn't run")

    def test_t8(self):
        self.assertRegisterEqual(self.MIPS.t8, self.MIPS.ra, "jal set incorrect return address")
