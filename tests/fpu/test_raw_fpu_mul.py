from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_mul(BaseCHERITestCase):
    def test_mul(self):
        '''Test we can multiply'''
        self.assertRegisterEqual(self.MIPS.s0, 0x4010000000000000, "Failed to multiply 2.0 and 2.0 in double precision");
        self.assertRegisterEqual(self.MIPS.s1, 0x41800000, "Failed to multiply 4.0 and 4.0 in single precision");
        self.assertRegisterEqual(self.MIPS.s2, 0x417000003F800000, "Failed to multiply 0.5, -1.0 and 5.0, -1.0 in paired single precision");
        self.assertRegisterEqual(self.MIPS.s3, 0x7F81000040800000, "Failed to echo QNaN");
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result");
