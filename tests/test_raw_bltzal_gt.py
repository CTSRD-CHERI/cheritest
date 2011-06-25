from bsim_utils import BaseBsimTestCase

class raw_bltzal_gt(BaseBsimTestCase):

    def test_before_bltzal(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bltzal missed")

    def test_bltzal_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bltzal_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
