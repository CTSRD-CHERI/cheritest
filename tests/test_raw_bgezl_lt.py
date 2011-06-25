from bsim_utils import BaseBsimTestCase

class raw_bgezl_lt(BaseBsimTestCase):

    def test_before_bgezl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgezl missed")

    def test_bgezl_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_bgezl_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
