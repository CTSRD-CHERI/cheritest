from cheritest_tools import BaseCHERITestCase

class test_raw_fpu_branch(BaseCHERITestCase):
    def test_branch(self):
        '''Test we can do branches'''
        self.assertRegisterEqual(self.MIPS.s0, 0x4, "Failed to branch on CC false");
        self.assertRegisterEqual(self.MIPS.s1, 0x3, "Failed to not branch on CC true");
        self.assertRegisterEqual(self.MIPS.s2, 0x3, "Failed to not branch on CC false");
        self.assertRegisterEqual(self.MIPS.s3, 0x4, "Failed to branch on CC true");
