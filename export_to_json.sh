#!/bin/bash
  FOLDER="/home/ubuntu/export_json/"
  FOLDER_DESTINATION="/home/ubuntu/export_json/Export/"
  for i in  counts daily_stats dork file hpfeed metadata session system.indexes url
  do
	  mongoexport --db mnemosyne --collection $i  --out $FOLDER_DESTINATION$i.json
	  #After export collections on json file, remove collections from MongoDB
	  STRING="db.$i.remove({})"
	  echo "Removing $i collection..." 
	  mongo mnemosyne --eval $STRING
  done
#Create archive with json file
tar -zcf "$(date '+%y%m%d%H%M%S').tar.gz" -C "$FOLDER_DESTINATION" .
#Clean json file
rm "$FOLDER_DESTINATION"*
#move archive to home folder
mv "$FOLDER"*".tar.gz" /home/ubuntu 
#test script funzionality
echo "ok" >> /home/ubuntu/log.txt
