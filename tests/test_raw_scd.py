from bsim_utils import BaseBsimTestCase

class raw_scd(BaseBsimTestCase):
    def test_store(self):
        '''Store conditional of word to double word'''
        self.assertRegisterEqual(self.MIPS.a0, 1, "Store conditional of word to double word failed")

    def test_load(self):
        '''Load of conditionally stored word from double word'''
        self.assertRegisterEqual(self.MIPS.a1, 0xfedcba987654321, "Load of conditionally stored word from double word failed")

    def test_store_positive(self):
        '''Store conditional of positive word'''
        self.assertRegisterEqual(self.MIPS.a2, 1, "Store conditional of positive word failed")

    def test_load_positive(self):
        '''Load of conditionally stored positive word'''
        self.assertRegisterEqual(self.MIPS.a3, 1, "Load of conditionally stored positive word failed")

    def test_store_negative(self):
        '''Store conditional of negative word'''
        self.assertRegisterEqual(self.MIPS.a4, 1, "Store conditional of negative word failed")

    def test_load_negative(self):
        '''Load of conditionally stored negative word'''
        self.assertRegisterEqual(self.MIPS.a5, 0xffffffffffffffff, "Load of conditionally stored negative word failed")

    def test_store_pos_offset(self):
        '''Store conditional of word at positive offset'''
        self.assertRegisterEqual(self.MIPS.a6, 1, "Store conditional of word at positive offset failed")

    def test_load_pos_offset(self):
        '''Load of conditionally stored word from positive offset'''
        self.assertRegisterEqual(self.MIPS.a7, 2, "Load of conditionally stored word at positive offset failed")

    def test_store_neg_offset(self):
        '''Store conditional of word at negative offset'''
        self.assertRegisterEqual(self.MIPS.s0, 1, "Store conditional of word at negative offset failed")

    def test_load_neg_offset(self):
        '''Load of conditionally stored word from negative offset'''
        self.assertRegisterEqual(self.MIPS.s1, 1, "Load of conditionally stored word at negative offset failed")
