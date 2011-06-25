from bsim_utils import BaseBsimTestCase

class raw_bgtzl_eq(BaseBsimTestCase):

    def test_before_bgtzl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgtzl missed")

    def test_bgtzl_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_bgtzl_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
