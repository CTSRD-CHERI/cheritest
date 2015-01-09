import sys
import subprocess
from string import Template

TEST_NAME = '../tests/fuzz_dma/test_clang_dma_generated_{0}.c'

def main():
    with open('test_template.c') as template_file:
        template = Template(template_file.read())

    try:
        tests = subprocess.check_output(
            ['../x86-obj/generate_dma_test', sys.argv[1], sys.argv[2]])
    except subprocess.CalledProcessError as ex:
        print ex.output
        return 1

    test_no = int(sys.argv[1]);
    for line in tests.rstrip().split('\n'):
        try:
            program, setsource, sourcesize, asserts, destsize = line.split('$')
        except Exception as ex:
            print test_no, ex, line
            break

        if len(setsource) == 0:
            print ('Test with seed {0} does no transfers, not '
                   'generated...'.format(test_no))
        else:
            with open(TEST_NAME.format(test_no), 'w') as out:
                out.write(template.substitute(
                    program=program, setsource=setsource, sourcesize=sourcesize,
                    asserts=asserts.replace(';', ';\n'), destsize=destsize))
        test_no += 1

    return 0

if __name__ == '__main__':
    main()
