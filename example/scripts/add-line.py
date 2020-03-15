#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sys
import getopt
import re


def findLine(pattern, fp):
    line = fp.readline()
    line_number = 1
    while line:
        #print("Line {}: {}".format(line_number, line.strip()))
        if pattern in line:
            return line_number
        line = fp.readline()
        line_number += 1
    return -1

def insertBefore(filename, pattern, text):
    with open(filename, 'r+') as fp:
        line_number = findLine(pattern, fp)
        if(line_number > 0):
            print 'Insert', text,'to line', line_number
            fp.seek(0)
            lines = fp.readlines()
            fp.seek(0)
            lines.insert(line_number - 1, text + '\n')
            fp.writelines(lines)
            return
        print 'pattern',text,'not found!'

def replaceText(filename, pattern, text):
    with open(filename, 'r') as fp:
        lines = fp.read()
        fp.close()
        lines = (re.sub(pattern, text, lines))
        print 'Replace', pattern ,'to', text
        fp = open(filename, 'w')
        fp.write(lines)
        fp.close()

def main(argv):
    inputfile = ''
    string = ''
    text = ''
    replace = False
    try:
        opts, args = getopt.getopt(argv, "hi:s:t:r")
    except getopt.GetoptError:
        print 'add-line.py -i <inputfile> -s <string> -t <text>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'add-line.py -i <inputfile> -s <string> -t <text>'
            sys.exit()
        elif opt in ("-i"):
            inputfile = arg
        elif opt in ("-s"):
            string = arg
        elif opt in ("-t"):
            text = arg
        elif opt in ("-r"):
            replace = True
    if(replace):
        replaceText(inputfile, string, text)
    else:
        insertBefore(inputfile, string, text)

if __name__ == "__main__":
    main(sys.argv[1:])
