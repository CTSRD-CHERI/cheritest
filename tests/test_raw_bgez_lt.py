from bsim_utils import BaseBsimTestCase

class raw_bgez_lt(BaseBsimTestCase):

    def test_before_bgez(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgez missed")

    def test_bgez_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgez_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
