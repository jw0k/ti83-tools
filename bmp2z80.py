#!/usr/bin/python

import sys
import argparse
from PIL import Image

parser = argparse.ArgumentParser(description="Convert indexed BMP into Z80 asm data")
parser.add_argument("path", help="path to the input BMP file")
parser.add_argument("-o", "--output", help="path to the output file")
args = parser.parse_args()

try:
    im = Image.open(args.path)
except IOError, e:
    print e
    sys.exit(2)

if (im.mode != 'P'):
    print "not a palette image file"
    sys.exit(2)

if (im.size[0] != 96 or im.size[1] != 64):
    print "bitmap size should be 96x64"
    sys.exit(2)

#00 - dark 0, light 0
#01 - dark 0, light 1
#10 - dark 1, light 0
#11 - dark 1, light 1

data = list(im.getdata())
darkData = [ bit/2 for bit in data ]
lightData = [ bit%2 for bit in data ]

darkLines = [ darkData[x:x+96] for x in xrange(0, len(darkData), 96) ]
lightLines = [ lightData[x:x+96] for x in xrange(0, len(lightData), 96) ]

if (args.output):
    sys.stdout = open(args.output, "w")

print "dark:"
for line in darkLines:
    bytesList = [ line[x:x+8] for x in xrange(0, len(line), 8) ]
    bytes = [ reduce(lambda x,y: x*2+y, bitList) for bitList in bytesList ]
    bytesInHex = [ "$"+format(byte, "02X") for byte in bytes ]
    print "    .db " + ",".join(bytesInHex)

print ""

print "light:"
for line in lightLines:
    bytesList = [ line[x:x+8] for x in xrange(0, len(line), 8) ]
    bytes = [ reduce(lambda x,y: x*2+y, bitList) for bitList in bytesList ]
    bytesInHex = [ "$"+format(byte, "02X") for byte in bytes ]
    print "    .db " + ",".join(bytesInHex)
