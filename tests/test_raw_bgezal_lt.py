from bsim_utils import BaseBsimTestCase

class raw_bgezal_lt(BaseBsimTestCase):

    def test_before_bgezal(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgezal missed")

    def test_bgezal_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgezal_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
