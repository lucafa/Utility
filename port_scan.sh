#!/bin/bash
NOME_FILE=$1
PORTE=$2
while read line
do
	while read ports 
		do
	nc -w 2 $line $ports		
	if [ $? -eq 0 ] 
	then
		echo "|"$line " : " $ports "| OPEN|" >> ./result_nc.txt
	else 
		echo "|"$line " : " $ports "|CLOSED|" >> ./result_nc.txt
	fi
	done < $PORTE
done < $NOME_FILE
