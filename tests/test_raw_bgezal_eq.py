from bsim_utils import BaseBsimTestCase

class raw_bgezal_eq(BaseBsimTestCase):
    def test_before_bgezal(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgezal missed")

    def test_bgezal_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in brach-delay slot missed")

    def test_bgezal_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "bgezal didn't branch")

    def test_bgezal_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")

    def test_bgezal_ra(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.ra, "bgezal ra incorrect")
