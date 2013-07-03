from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_add(BaseCHERITestCase):
    def test_add(self):
        '''Test we can add'''
        self.assertRegisterEqual(self.MIPS.s1, 0x40000000, "Failed to add 1.0 and 1.0 in single precision")
        self.assertRegisterEqual(self.MIPS.s0, 0x4000000000000000, "Failed to add 1.0 and 1.0 in double precision")
        self.assertRegisterEqual(self.MIPS.s2, 0x000000004250C28f, "Failed paired single add")
        self.assertRegisterEqual(self.MIPS.s3, 0x4000000040800000, "Failed to add 1.0, 2.0 and 1.0, 2.0 in paired single precision")

    def test_add_edge_cases(self):
        self.assertRegisterEqual(self.MIPS.s4, 0x0, "Failed to flush denormalised result")
