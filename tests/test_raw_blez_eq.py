from bsim_utils import BaseBsimTestCase

class raw_blez_eq(BaseBsimTestCase):
    def test_before_blez(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before forward blez missed")

    def test_blez_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_blez_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_blez_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
