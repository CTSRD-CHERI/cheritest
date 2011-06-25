from bsim_utils import BaseBsimTestCase

class test_reg_zero(BaseBsimTestCase):
    def test_zero(self):
        '''Test that register zero is zero'''
        self.assertRegisterEqual(self.MIPS.zero, 0, "Register zero has non-zero value on termination")

    def test_t0(self):
        '''Test that move from zero is zero'''
        self.assertRegisterEqual(self.MIPS.t0, 0, "Move from register zero non-zero")

    def test_t1(self):
        '''Test that immediate store of non-zero to zero returns zero'''
        self.assertRegisterEqual(self.MIPS.t1, 0, "Immediate store to regster zero succeeded")

    def test_t2(self):
        '''Test that register store of nonzero to zero returns zero'''
        self.assertRegisterEqual(self.MIPS.t2, 0, "Register move to register zero succeeded")
