import secrets
import random
from decimal import Decimal
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
     

file = open("tracefileLRU.txt", "w") 
for i in range(1,numLines):
    hex32bit = randhex() + randhex() +tagbits() + randhex1() + randhex1_2()
    file.write(str(busOps)  )
    file.write("  ")
    file.write(hex32bit)
    file.write("\n")
print(hex32bit)
file.close()