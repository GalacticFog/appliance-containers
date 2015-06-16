#!/usr/bin/python

import sys, json

data = json.load(sys.stdin)

for i in range(1,len(sys.argv)):
	print data[sys.argv[i]],
