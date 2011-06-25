from bsim_utils import BaseBsimTestCase

class raw_bne_lt_back(BaseBsimTestCase):
    def test_before_bne(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before backward bne missed")

    def test_bne_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bne_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_bne_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
