from bsim_utils import BaseBsimTestCase

class raw_bgtz_eq(BaseBsimTestCase):

    def test_before_bgtz(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgtz missed")

    def test_bgtz_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in branch-delay slot missed")

    def test_bgtz_notskipped(self):
        self.assertRegisterEqual(self.MIPS.a2, 3, "instruction after branch-delay slot missed")
