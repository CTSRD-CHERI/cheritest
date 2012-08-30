from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_pair(BaseCHERITestCase):
    def test_pair(self):
        '''Test we can do pairwise merging'''
        self.assertRegisterEqual(self.MIPS.a0, 0x3F80000040000000, "Failed to merge paired lower, lower");
        self.assertRegisterEqual(self.MIPS.a1, 0xBF8000003F800000, "Failed to merge paired lower, upper");
        self.assertRegisterEqual(self.MIPS.a2, 0x7F80000000000000, "Failed to merge paired upper, lower");
        self.assertRegisterEqual(self.MIPS.a3, 0x7F8000003F800000, "Failed to merge paired upper, upper");
