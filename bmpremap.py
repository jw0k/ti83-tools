#!/usr/bin/python

import sys
import argparse
from PIL import Image

parser = argparse.ArgumentParser(description="Modify indices in a BMP with a color table (palette)")
parser.add_argument("path", help="path to the input BMP file")
group = parser.add_mutually_exclusive_group()
group.add_argument("-i", "--indices", nargs="+", help="any permutation of indices")
group.add_argument("-s", "--sort", action="store_true", help="sort colors from lightest to darkest by R channel")
parser.add_argument("-m", "--max-contrast", action="store_true", help="maximizes contrast")
args = parser.parse_args()

if (not args.max_contrast):
    if (not args.indices) and (not args.sort):
        parser.print_usage()
        sys.exit(2)

try:
    im = Image.open(args.path)
except IOError, e:
    print e
    sys.exit(2)

if (im.mode != 'P'):
    print "not a palette image file"
    sys.exit(2)

INCORRECTSTR = "incorrect permutation"

if (args.sort):
    p = im.getpalette()
    redvalues = []
    for i in range(len(im.getcolors())):
        redvalues.append((p[i*3], i))
    redvalues.sort(reverse=True)
    indices = [ x[1] for x in redvalues ]
elif (args.indices):
    try:
        indices = [ int(x) for x in args.indices ]
    except ValueError:
        print INCORRECTSTR
        sys.exit(2)

    for ind in indices:
        if (ind < 0 or ind > 255):
            print INCORRECTSTR
            sys.exit(2)

    if len(indices) > len(set(indices)): #check if not unique
        print INCORRECTSTR
        sys.exit(2)
else:
    indices = range(len(im.getcolors()))

numColors = len(im.getcolors())
numIndices = len(indices)

if numColors != numIndices:
    print ("image has " + str(numColors) + " colors so the permutation should have " +
           str(numColors) + " indices but it has " + str(numIndices))
    sys.exit(2)

im2 = im.point([x[1] for x in sorted(zip(indices, range(numIndices)))] + [0]*(256-numIndices))

pal = im.getpalette()
pal2 = list(pal) #you can't just say "pal2 = pal", it would not make a copy

for i, index in enumerate(indices):
    pal2[i*3+0] = pal[index*3+0]
    pal2[i*3+1] = pal[index*3+1]
    pal2[i*3+2] = pal[index*3+2]

if (args.max_contrast):
    step = 255.0/(numColors-1)
    vals = [ int(round(s*step)) for s in range(numColors-1) ]
    vals.append(255)

    redvalues = [];
    for i in range(numColors):
        redvalues.append((pal2[i*3], i))
    redvalues.sort()

    newvals = zip([ x[1] for x in redvalues ], vals)
    newvals.sort()
    newvals = [x[1] for x in newvals]
    for i, x in enumerate(newvals):
        pal2[i*3+0] = x
        pal2[i*3+1] = x
        pal2[i*3+2] = x

im2.putpalette(pal2)

#this forces im to release the file handle to prevent "permission denied" error upon im2.save;
#calling im.close seems not to be enough (probably a bug in Pillow)
im = None

im2.save(args.path)
im2.close()
