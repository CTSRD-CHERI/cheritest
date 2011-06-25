from bsim_utils import BaseBsimTestCase

class raw_bgezl_eq(BaseBsimTestCase):
    def test_before_bgezl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before forward bgezl missed")

    def test_bgezl_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgezl_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_bgezl_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
