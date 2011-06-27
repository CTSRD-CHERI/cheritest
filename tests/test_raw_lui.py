from bsim_utils import BaseBsimTestCase

class raw_lui(BaseBsimTestCase):
    def test_lui_replace(self):
        '''Check that existing data is entirely overwritten by lui'''
        self.assertRegisterEqual(self.MIPS.a0, 0, "lui didn't overwrite all bits")

    def test_lui_positive(self):
        '''Load a large positive value using lui'''
        self.assertRegisterEqual(self.MIPS.a1, 0x7fff0000, "lui of 0x7fff failed")

    def test_lui_negative(self):
        '''Load a large negative value using lui'''
        self.assertRegisterEqual(self.MIPS.a2, 0xffffffffffff0000, "lui of 0xffff failed")
