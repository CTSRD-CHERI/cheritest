import fileinput
from string import Template

def main():
    with open('TestTemplate.c') as template_file:
        template = Template(template_file.read())
    for line in fileinput.input():
        program, setsource, sourcesize, asserts, destsize = line.split('$')
        print template.substitute(
            program=program, setsource=setsource, sourcesize=sourcesize,
            asserts=asserts, destsize=destsize)

if __name__ == '__main__':
    main()
