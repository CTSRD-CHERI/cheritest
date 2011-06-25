from bsim_utils import BaseBsimTestCase

class raw_jump(BaseBsimTestCase):
    def test_j_before(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before j missed")

    def test_j_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a2, 2, "instruction in branch-delay slot missed")

    def test_j_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a3, 3, "jump didn't happen")

    def test_j_target(self):
        self.assertRegisterEqual(self.MIPS.a4, 4, "instruction at jump target didn't run")
