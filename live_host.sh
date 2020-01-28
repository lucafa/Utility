#!/bin/bash
NOME_FILE=$1
while read line
do
	ping -c 2 $line
	if [ $? -eq 0 ] 
	then
		echo "|"$line"|Pingabile|" >> ./result.txt
	else 
		echo "|"$line "|NON Pingabile|" >> ./result.txt
	fi
done < $NOME_FILE

