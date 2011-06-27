from bsim_utils import BaseBsimTestCase

class test_dadd_overflow(BaseBsimTestCase):
    def test_epc(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "Unexpected EPC")

    def test_returned(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "flow broken by dadd instruction")

    def test_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "dadd exception handler not run")

    def test_exl_in_handler(self):
        self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

    def test_cause_bd(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 0, "Branch delay (BD) flag improperly set")

    def test_cause_code(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, 13, "Code not set to Tr")

    def test_not_exl_after_handler(self):
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 0, "EXL still set after ERET")
