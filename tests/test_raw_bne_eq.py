from bsim_utils import BaseBsimTestCase

class raw_bne_eq(BaseBsimTestCase):

    def test_before_bne(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bne missed")

    def test_bne_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bne_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
