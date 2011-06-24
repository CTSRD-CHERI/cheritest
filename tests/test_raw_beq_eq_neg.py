from bsim_utils import BaseBsimTestCase

class raw_beq_eq_neg(BaseBsimTestCase):
    def test_before_beq(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before backward beq missed")

    def test_beq_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_beq_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "branch didn't happen")

    def test_beq_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")
