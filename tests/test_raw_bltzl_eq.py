from bsim_utils import BaseBsimTestCase

class raw_bltzl_eq(BaseBsimTestCase):

    def test_before_bltzl(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bltzl missed")

    def test_bltzl_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_bltzl_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
