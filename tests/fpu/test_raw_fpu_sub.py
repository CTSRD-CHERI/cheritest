from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_sub(BaseCHERITestCase):
    def test_sub(self):
        '''Test we can subtract'''
        self.assertRegisterEqual(self.MIPS.s1, 0xFFFFFFFFC0000000, "Failed to subtract 4.0 from 2.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s0, 0x3FF0000000000000, "Failed to subtract 1.0 from 2.0 in double precision")
        self.assertRegisterEqual(self.MIPS.s2, 0x41C8000042000000, "Failed paired single subtract.")

    def test_sub_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s3, 0x7F81000000000000, "Failed to echo QNaN")
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result")
