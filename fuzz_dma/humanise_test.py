import sys
import re

def humanise_asserts(line):
    prologue = '\tassert(1 && '
    epilogue = ' );\n'
    assert line.startswith(prologue)
    assert line.endswith(epilogue)
    line = line[len(prologue):-len(epilogue)]
    asserts = line.split(' && ')
    return ['\tassert({0});\n'.format(a) for a in asserts]

def arithmetic_target(value):
    return 'AT_{0}'.format(
        'BOTH' if value == 0 else (
        'SOURCE_ONLY' if value == 1 else (
        'DEST_ONLY' if value == 2 else (
        'ERROR'))))

def int_to_macro(instruction):
    opcode = instruction >> 28
    reg = (instruction >> 26) & 3
    value = instruction & 0x3FFFFFF
    if opcode == 0:
        return 'DMA_OP_SET(LOOP_REG_{0}, {1})'.format(reg, value)
    elif opcode == 1:
        return 'DMA_OP_LOOP(LOOP_REG_{0}, {1})'.format(reg, value)
    elif opcode == 2:
        transfer_size = 8 * (1 << ((instruction >> 25) & 0x7))
        return 'DMA_OP_TRANSFER(TS_BITS_{0})'.format(transfer_size)
    elif opcode == 4:
        return 'DMA_OP_ADD({0}, {1})'.format(arithmetic_target(reg), value)
    elif opcode == 5:
        return 'DMA_OP_SUB({0}, {1})'.format(arithmetic_target(reg), value)
    elif opcode == 6:
        return 'DMA_OP_STOP'
    else:
        assert False

def match_to_macro(match):
    return int_to_macro(int(match.group(0), 16))

def humanise_programs(line):
    line = line.replace('{', '{\n').replace('}', '\n}').replace(',', ',\n\t')
    line = re.sub('0x[0-9a-f]{8}', match_to_macro, line)
    return line

def main():
    new_file = []
    with open(sys.argv[1]) as test_file:
        for line in test_file:
            if line.strip().startswith('assert(1 &&'):
                new_file.extend(humanise_asserts(line))
            elif line.strip().startswith('source_addrs'):
                new_file.append(line.replace(';', ';\n\t'))
            elif line.strip().startswith('dma_instruction *dma_program[]'):
                new_file.append(humanise_programs(line))
            else:
                new_file.append(line)

    with open(sys.argv[1], 'w') as test_file:
        test_file.write(''.join(new_file))

if __name__ == '__main__':
    main()
