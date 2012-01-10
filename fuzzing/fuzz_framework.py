
NUM_GREGS=32

class Variation(object):
    pass

class EnumVariation(Variation):
    def __init__(self, values):
        self.values=values

    def iterate_values(self):
        for v in self.values:
            yield v

class RegisterVariation(EnumVariation):
    def __init__(self):
        super(RegisterVariation, self).__init__(("$r%d"%n for n in range(NUM_GREGS)))

class RRROpcodeVariation(EnumVariation):
    opcodes = """
    ADD
    ADDU
    SUB
    SUBU
    SLT
    SLTU
    AND
    OR
    XOR
    NOR 
    """.split()
    def __init__(self):
        super(RRROpcodeVariation, self).__init__(RRROpcodeVariation.opcodes)

class CrossVariation(Variation):
    def iterate_values(self):
        variations=inspect.getmembers(self.__class__, lambda m: isinstance(m,Variation))
        for p in itertools.product(*(v[1].iterate_values() for v in variations)):
            yield dict((variations[i][0],p[i]) for i in xrange(len(variations)))

class MIPSInstruction(CrossVariation):
    pass

class RRRInstructions(MIPSInstruction):
    opcode=RRROpcodeVariation()
    rd=RegisterVariation()
    rs=RegisterVariation()
    rt=RegisterVariation()

    def iterate_asm(self):
        for v in self.iterate_values():
            yield "%(opcode)s %(rd)s, %(rs)s, %(rt)s"%v    

class TestGenerator(object):
    pass

class InstructionPairGenerator(TestGenerator):
    
    def generate_test(self, n):
        pass
