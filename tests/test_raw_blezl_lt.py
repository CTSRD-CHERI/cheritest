from bsim_utils import BaseBsimTestCase

class raw_blezl_lt(BaseBsimTestCase):
    def test_before_blezl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before forward blezl missed")

    def test_blezl_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_blezl_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_blezl_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
