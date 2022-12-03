#author Bendjy Faurestal
#generate a file with custom command(busOps) and 32 bit hex data
import os
import secrets
import random
from decimal import Decimal


cwd = os.getcwd()
nameOfFile = "tracefileLRU.txt"
busOps = 0;
numLines= 13
n=0x17 
tagBitsVal = Decimal(n-1) #value for tagbits

def randhex1():
    return str(random.choice("1"))
def randhex1_2():
    return str(random.choice("2345670ABC"))
def randhex():
    return str(random.choice("0123456789ABCDEF")) + str(random.choice("0123456789ABCDEF"))
def tagbits():
    return str(tagBitsVal)
     
print("Current working directory:",cwd)
filename = cwd+'/' + nameOfFile
file = open(filename,"w") 
for i in range(1,numLines):
    hex32bit = tagbits() + randhex1() + randhex() + randhex() +  randhex1_2()
    file.write(str(busOps)  )
    file.write("  ")
    file.write(hex32bit)
    file.write("\n")
print("file successfully written")
file.close()