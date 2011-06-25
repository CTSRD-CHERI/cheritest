from bsim_utils import BaseBsimTestCase

class raw_bltz_gt(BaseBsimTestCase):

    def test_before_bltz(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bltz missed")

    def test_bltz_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bltz_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
