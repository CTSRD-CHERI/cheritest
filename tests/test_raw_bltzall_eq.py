from bsim_utils import BaseBsimTestCase

class raw_bltzall_eq(BaseBsimTestCase):

    def test_before_bltzall(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bltzall missed")

    def test_bltzall_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 0, "instruction in branch-delay slot executed")

    def test_bltzall_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
