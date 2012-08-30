from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_cntrl(BaseCHERITestCase):
    def test_movc(self):
        '''Test to ensure we can move 32 bits between COP1 and GPR registers'''
        self.assertRegisterEqual(self.MIPS.s0, 9, "MOVC failed")
        
    def test_dmovc(self):
        '''Test to ensure we can move 64 bits between COP1 and GPR registers'''
        self.assertRegisterEqual(self.MIPS.s1, (18 << 32) + 7, "DMOVC failed");
        
    def test_cmovc(self):
        '''Test to ensure control registers are correctly read and written'''
        self.assertRegisterEqual(self.MIPS.s2, 0x3F, "CMOVC failed for $f25");
        self.assertRegisterEqual(self.MIPS.s3, 0xF070, "CMOVC failed for $f26");
        self.assertRegisterEqual(self.MIPS.s4, 0xF86, "CMOVC failed for $f28");
        self.assertRegisterEqual(self.MIPS.s5, 0x0003FFFF, "CMOVC failed for $f31");
        
        self.assertRegisterEqual(self.MIPS.s6, 0x00000F83, "CMFC failed to interpret $f31 for $f28");
        self.assertRegisterEqual(self.MIPS.s7, 0x0003F07C, "CMFC failed to interpret $f31 for $f26");
        self.assertRegisterEqual(self.MIPS.a0, 0x0, "CMFC failed to interpret $f31 for $f25");
        
    def test_cmov(self):
        '''Test to ensure we can move values between FPRs'''
        self.assertRegisterEqual(self.MIPS.t8, 0x41000000, "CMOV failed for single precision");
        self.assertRegisterEqual(self.MIPS.t3, 0x4000000000000000, "CMOV failed for double precision");
        self.assertRegisterEqual(self.MIPS.t2, 0x4000000041000000, "CMOV failed for paired single precision");
