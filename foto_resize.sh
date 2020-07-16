#!/bin/bash
for i in `find . -iname '*.jpg' -type f`
do
	
	if [[ -f $i ]]; then
		SIZE=`stat --printf="%s" $i`
		ABS_PATH=${i#?};
		DEST_PATH="/home/luca/foto_resize"$ABS_PATH
		FOLDER=`dirname $DEST_PATH`
		if [[ ! -d $FOLDER ]];then
			mkdir  -p $FOLDER
		fi
		if [[  $SIZE -gt 3000000 ]];then
			convert -resize 25% $i $DEST_PATH
		elif [[ $SIZE -le 1000000 ]]; then
			cp $i $DEST_PATH
		else 
			convert -resize 50% $i $DEST_PATH
		fi
	fi	
	
done

