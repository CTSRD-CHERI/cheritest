from bsim_utils import BaseBsimTestCase

class raw_beq_gt(BaseBsimTestCase):

    def test_before_beq(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before beq missed")

    def test_beq_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_beq_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
