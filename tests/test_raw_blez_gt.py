from bsim_utils import BaseBsimTestCase

class raw_blez_gt(BaseBsimTestCase):

    def test_before_blez(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before blez missed")

    def test_blez_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_blez_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
