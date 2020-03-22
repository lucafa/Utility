#!/bin/bash
FILE=$1
COUNTER=$2
cp $FILE ./file_1
for i in `seq 1 $COUNTER`;
        do

    echo "STEP NUMBER $i"
		base64 -d ./file_1 > ./temp_file 
		mv ./temp_file ./file_1
		cat ./file_1

done 
