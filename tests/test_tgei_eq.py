from bsim_utils import BaseBsimTestCase

class test_tgei_eq(BaseBsimTestCase):
    def test_tgei_epc(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "Unexpected EPC")

    def test_tgei_returned(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "flow broken by tgei instruction")

    def test_tgei_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "tgei exception handler not run")

    def test_tgei_exl_in_handler(self):
        self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

    def test_tgei_cause_bd(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 0, "Branch delay (BD) flag improperly set")

    def test_tgei_cause_code(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, 13, "Code not set to Tr")

    def test_tgei_not_exl_after_handler(self):
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 0, "EXL still set after ERET")
