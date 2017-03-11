#!/usr/bin/python

import sys, re

# if sys.platform == "win32":
    # import os, msvcrt
    # msvcrt.setmode(sys.stdout.fileno(), os.O_BINARY)

if len(sys.argv) != 3:
    print "usage: fix83p.py path/to/invalid83p path/to/output"
    sys.exit(2)

try:
    f = open(sys.argv[1], "rb") # r - read, b - binary
except Exception, e:
    print str(e)
    sys.exit(1)

try:
    content = bytearray(f.read())

    newContent = bytearray(content[0:72]) # this copies bytes from 0 to 71 inclusive (not 72)

    for byte in content[72:-2]:
        byteAsTwoCharacterString = format(byte, '02X')
        newContent.append(ord(byteAsTwoCharacterString[0]))
        newContent.append(ord(byteAsTwoCharacterString[1]))

    # add tokenized "\nend\n0000\nend" at the end
    newContent.append(0x3F)
    newContent.append(0xD4)
    newContent.append(0x3F)
    newContent.append(0x30)
    newContent.append(0x30)
    newContent.append(0x30)
    newContent.append(0x30)
    newContent.append(0x3F)
    newContent.append(0xD4)


    progLength = len(newContent)-72
    dataLength = progLength+2
    fileLength = progLength+0x11

    #fix file length
    newContent[0x35] = fileLength%256
    newContent[0x36] = fileLength/256

    #fix first data length
    newContent[0x39] = dataLength%256
    newContent[0x3A] = dataLength/256

    # fix second data length
    newContent[0x44] = dataLength%256
    newContent[0x45] = dataLength/256

    # fix program length
    newContent[0x46] = progLength%256
    newContent[0x47] = progLength/256

    # 5 - make program editable; 6 - make program uneditable
    newContent[0x3B] = 5

    # checksum - 16 bit sum from byte 0x37
    checksum = sum(newContent[0x37:])%65536
    newContent.append(checksum%256)
    newContent.append(checksum/256)

    # sys.stdout.write(newContent)

    try:
        newFile = open(sys.argv[2], "wb")
    except Exception, e:
        print str(e)
        sys.exit(1)

    try:
        newFile.write(newContent)
    finally:
        newFile.close()

finally:
    f.close()
