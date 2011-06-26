from bsim_utils import BaseBsimTestCase

class raw_jr(BaseBsimTestCase):
    def test_before_jr(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before jr missed")

    def test_jr_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a2, 2, "instruction in branch-delay slot missed")

    def test_jr_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a3, 3, "jump didn't happen")

    def test_jr_target(self):
        self.assertRegisterEqual(self.MIPS.a4, 4, "instruction at jump target didn't run")
