#!/usr/bin/python

tableName = raw_input("Insert table name ")

tableSplit = list(tableName)
sqlString = "CHAR("
for i in range(len(tableSplit)):
    numero=str(ord(tableSplit[i]))
    sqlString += numero + ", " 


sqlString = sqlString[:-2]
sqlString += ")"
print sqlString
