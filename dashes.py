#!/usr/bin/env python

import sys

with open(sys.argv[1], 'r') as my_file:
	dict ={}
	for line in my_file:
		line = line.strip()
		if line.startswith(">"):
			ID = line
			dict[ID] = ''		
		else:
			dict[ID] += line
			
# look at each position in each dictionary value, if it is not "A", C, T, or G, remove that position from each string	
for key in dict.keys():
	i=0
	while i < len(dict[key]):
		if dict[key][i] not in ['A','C','T','G','a','c','t','g']:
			for species in dict.keys():
				val = list(dict[species])
				val.pop(i)
				dict[species] = ''.join(val)	
		else:
			i +=1
for key, value in dict.items():
	print(key)
	print(value)
