from bsim_utils import BaseBsimTestCase

class test_code_rom_relocation(BaseBsimTestCase):
    def test_t0(self):
        self.assertRegisterEqual(self.MIPS.t0, 1, "instruction before jump missed")

    def test_t1(self):
        self.assertRegisterEqual(self.MIPS.t1, 2, "relocated handler did not run")

    def test_t2(self):
        self.assertRegisterEqual(self.MIPS.t2, 3, "relocated handler did not return");
