from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_mov_cc(BaseCHERITestCase):
    def test_mov_cc(self):
        '''Test we can move on CCs'''
        self.assertRegisterEqual(self.MIPS.s0, 0x41000000, "Failed MOVF on condition true in single precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x4000000000000000, "Failed MOVF on condition true in double precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x4000000041000000, "Failed MOVF on condition true in paired single precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x0, "Failed MOVF on condition false in single precision");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed MOVF on condition false in double precision");
        self.assertRegisterEqual(self.MIPS.s5, 0x0, "Failed MOVF on condition false in paired single precision");
        self.assertRegisterEqual(self.MIPS.s6, 0x41000000, "Failed MOVT on condition true in single precision");
        self.assertRegisterEqual(self.MIPS.s7, 0x4000000000000000, "Failed MOVT on condition true in double precision");
        self.assertRegisterEqual(self.MIPS.a0, 0x4000000041000000, "Failed MOVT on condition true in paired single precision");
        self.assertRegisterEqual(self.MIPS.a1, 0x0, "Failed MOVT on condition false in single precision");
        self.assertRegisterEqual(self.MIPS.a2, 0x0, "Failed MOVT on condition false in double precision");
        self.assertRegisterEqual(self.MIPS.a3, 0x0, "Failed MOVT on condition false in paired single precision");
