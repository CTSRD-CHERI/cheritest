from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_recip(BaseCHERITestCase):
    def test_recip(self):
        '''Test we can take reciprocals'''
        self.assertRegisterEqual(self.MIPS.s0, 0x3FB0000000000000, "Failed to take the reciprocal of 16.0 in double precision")
        self.assertRegisterEqual(self.MIPS.s1, 0x7F800000, "Failed to take the reciprocal of 0.0 in single precision")

    def test_recip_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x7FF1000000000000, "Failed to echo QNaN")
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result")
