from bsim_utils import BaseBsimTestCase

class test_hilo(BaseBsimTestCase):
    def test_hilo_set_hi(self):
        self.assertRegisterEqual(self.MIPS.a2, 0xe624379d7daf6318, "HI not preserved across set/get")

    def test_hilo_set_lo(self):
        self.assertRegisterEqual(self.MIPS.a3, 0x608467ffc8a78552, "LO not preserved across set/get")

    def test_hilo_dmult(self):
        self.assertRegisterEqual(self.MIPS.a4, 0x0469266d00323390, "HI incorrect after dmult")
        self.assertRegisterEqual(self.MIPS.a5, 0xe2492cdfae99444a, "LO incorrect after dmult")

    def test_hilo_ddiv(self):
        self.assertRegisterEqual(self.MIPS.a6, 0x2aa7f6bfd4716e30, "HI incorrect after ddiv")
        self.assertRegisterEqual(self.MIPS.a7, 0x1, "LO incorrect after ddiv")
