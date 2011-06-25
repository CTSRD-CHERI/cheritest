from bsim_utils import BaseBsimTestCase

class raw_bgtz_gt(BaseBsimTestCase):
    def test_before_bgtz(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before forward bgtz missed")

    def test_bgtz_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgtz_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_bgtz_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
