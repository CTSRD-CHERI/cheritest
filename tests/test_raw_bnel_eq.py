from bsim_utils import BaseBsimTestCase

class raw_bnel_eq(BaseBsimTestCase):

    def test_before_bnel(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bnel missed")

    def test_bnel_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_bnel_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
