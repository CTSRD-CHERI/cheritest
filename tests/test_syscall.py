from bsim_utils import BaseBsimTestCase

class test_syscall(BaseBsimTestCase):
    def test_syscall_epc(self):
        self.assertRegisterEqual(self.MIPS.a0, self.MIPS.a5, "Unexpected EPC")

    def test_syscall_returned(self):
        self.assertRegisterEqual(self.MIPS.a1, 1, "flow broken by syscall instruction")

    def test_syscall_handled(self):
        self.assertRegisterEqual(self.MIPS.a2, 1, "syscall exception handler not run")

    def test_syscall_exl_in_handler(self):
        self.assertRegisterEqual((self.MIPS.a3 >> 1) & 0x1, 1, "EXL not set in exception handler")

    def test_syscall_cause_bd(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 31) & 0x1, 0, "Branch delay (BD) flag improperly set")

    def test_syscall_cause_code(self):
        self.assertRegisterEqual((self.MIPS.a4 >> 2) & 0x1f, 8, "Code not set to Sys")

    def test_syscall_not_exl_after_handler(self):
        self.assertRegisterEqual((self.MIPS.a6 >> 1) & 0x1, 0, "EXL still set after ERET")
