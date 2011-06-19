from bsim_utils import BaseBsimTestCase

class test_exception_bev0_trap_bd(BaseBsimTestCase):
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "EPC not set properly")

    def test_bd_eret(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "trap skipped eret target")

    def test_bd_offby4(self):
        self.assertRegisterEqual(self.MIPS.a6, 1, "trap skipped eret target+4")

    def test_bev1_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "exception handler not run")

    def test_cause_bd(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 1, "Branch delay (BD) flag not set")

    def test_cause_code(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, 13, "Code not set to Tr")
