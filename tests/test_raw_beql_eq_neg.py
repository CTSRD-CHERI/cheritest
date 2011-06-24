from bsim_utils import BaseBsimTestCase

class raw_beql_eq_neg(BaseBsimTestCase):
    def test_before_beql(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before backward beql missed")

    def test_beql_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_beql_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_beql_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
