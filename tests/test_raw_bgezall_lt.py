from bsim_utils import BaseBsimTestCase

class raw_bgezall_lt(BaseBsimTestCase):

    def test_before_bgezall(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgezall missed")

    def test_bgezall_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgezall_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
