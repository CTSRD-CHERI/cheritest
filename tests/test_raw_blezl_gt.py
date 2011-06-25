from bsim_utils import BaseBsimTestCase

class raw_blezl_gt(BaseBsimTestCase):

    def test_before_blezl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before blezl missed")

    def test_blezl_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_blezl_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
