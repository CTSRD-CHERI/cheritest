from bsim_utils import BaseBsimTestCase

class raw_bltzal_lt(BaseBsimTestCase):
    def test_before_bltzal(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bltzal missed")

    def test_bltzal_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in brach-delay slot missed")

    def test_bltzal_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "bltzal didn't branch")

    def test_bltzal_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")

    def test_bltzal_ra(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.ra, "bltzal ra incorrect")
