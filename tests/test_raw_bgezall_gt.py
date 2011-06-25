from bsim_utils import BaseBsimTestCase

class raw_bgezall_gt(BaseBsimTestCase):
    def test_before_bgezall(self):
        self.assertRegisterEqual(self.MIPS.a0, 1, "instruction before bgezall missed")

    def test_bgezall_branch_delay(self):
        self.assertRegisterNotEqual(self.MIPS.a1, 2, "instruction in brach-delay slot taken")

    def test_bgezall_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "bgezall didn't branch")

    def test_bgezall_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")

    def test_bgezall_ra(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.ra, "bgezall ra incorrect")
