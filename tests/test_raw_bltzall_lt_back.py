from bsim_utils import BaseBsimTestCase

class raw_bltzall_lt_back(BaseBsimTestCase):
    def test_before_bltzall(self):
        self.assertRegisterNotEqual(self.MIPS.a0, 0, "instruction before bltzall missed")

    def test_bltzall_branch_delay(self):
        self.assertRegisterEqual(self.MIPS.a1, 2, "instruction in brach-delay slot missed")

    def test_bltzall_skipped(self):
        self.assertRegisterNotEqual(self.MIPS.a2, 3, "bltzall didn't branch")

    def test_bltzall_target(self):
        self.assertRegisterEqual(self.MIPS.a3, 4, "instruction at branch target didn't run")

    def test_bltzall_ra(self):
        self.assertRegisterEqual(self.MIPS.a4, self.MIPS.ra, "bltzall ra incorrect")
