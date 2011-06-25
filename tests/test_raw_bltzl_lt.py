from bsim_utils import BaseBsimTestCase

class raw_bltzl_lt(BaseBsimTestCase):
    def test_before_bltzl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before forward bltzl missed")

    def test_bltzl_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bltzl_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_bltzl_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
