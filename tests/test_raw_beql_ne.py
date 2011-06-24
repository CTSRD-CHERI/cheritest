from bsim_utils import BaseBsimTestCase

class raw_beql_ne(BaseBsimTestCase):

    def test_before_beql(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before beql missed")

    def test_beql_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in branch-delay slot taken")

    def test_beql_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
