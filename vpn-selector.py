#!/usr/bin/python

import os,sys,termios,tty,subprocess
path=os.getenv("HOME")+"/Documents/OpenVPN"


os.system("clear")

if (len(sys.argv) > 1):
	argspath = sys.argv[1]
	if os.path.isdir(argspath) == True:
		path = argspath;
	else:
		print "The paramente isn't a folder"

dirList=os.listdir(path)

vpns=[]

for filename in dirList:
	path2=path+"/"+filename
	if os.path.isdir(path2) == False:
		continue

	dir2List= os.listdir(path2)
	for filename2 in dir2List:
		if filename2.endswith(".ovpn"):
			vpns.append([filename,path2,filename2])

i=0
for vpn in vpns:
	i=i+1
	print str(i)+")"+" "+vpn[0] + " - " + vpn[2][:-5]


fd = sys.stdin.fileno()
old_settings = termios.tcgetattr(fd)
ch=''
try:
	tty.setraw(sys.stdin.fileno())
	ch = sys.stdin.read(1)
finally:
	termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
	

try:
	selection=int(ch)
	path=str(vpns[selection-1][1])
	os.chdir(path)
	args="--config "+ str(vpns[selection-1][2])
	subprocess.call(["sudo openvpn " + args], shell=True)
except:
	print "Wrong selection"
