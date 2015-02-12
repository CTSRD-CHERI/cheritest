import sys

def humanise_asserts(line):
    prologue = '\tassert(1 && '
    epilogue = ' );\n'
    assert line.startswith(prologue)
    assert line.endswith(epilogue)
    line = line[len(prologue):-len(epilogue)]
    asserts = line.split(' && ')
    return ['\tassert({0});\n'.format(a) for a in asserts]

def main():
    new_file = []
    with open(sys.argv[1]) as test_file:
        for line in test_file:
            if line.strip().startswith('assert'):
                new_file.extend(humanise_asserts(line))
            else:
                new_file.append(line)

    with open(sys.argv[1], 'w') as test_file:
        test_file.write(''.join(new_file))

if __name__ == '__main__':
    main()
