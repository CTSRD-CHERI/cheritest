from bsim_utils import BaseBsimTestCase

class raw_bgez_eq_back(BaseBsimTestCase):
    def test_before_bgez(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before backward bgez missed")

    def test_bgez_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgez_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_bgez_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
