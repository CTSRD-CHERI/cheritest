from bsim_utils import BaseBsimTestCase

class raw_jalr(BaseBsimTestCase):
    def test_before_jalr(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before jalr missed")

    def test_jalr_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a3, 3, "instruction in branch-delay slot missed")

    def test_jalr_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a4, 4, "jump didn't happen")

    def test_jalr_target(self):
        self.assertRegisterEqual(self.MIPS.a5, 5, "instruction at jump target didn't run")

    def test_jalr_ra(self):
        self.assertRegisterEqual(self.MIPS.ra, 0, "ra improperly set after jalr")

    def test_jalr_reg(self):
        self.assertRegisterEqual(self.MIPS.a1, self.MIPS.a2, "a2 not set to return address by jalr")
