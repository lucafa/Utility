#!/bin/bash

### VARIABILI
FILE_CONFIG="/home/luca/bck_config"
FILE_FOLDER="/home/luca/bck_folder"
FILE_LOG="/home/luca/backup_log"
SSH_FILE="/home/luca/.ssh/id_fileserver_rsa"

### CHECK FILESERVER
ping -c 2 lf-fileserver 
if [ $? == 0 ]; then
	nc -z lf-fileserver 22
	if [ $? != 0 ]; then 
		echo "ERRORE Fileserver non raggiungibile" >> $FILE_LOG
    fi
fi

### READ FILE AND BACKUP
while read line 
do
	/usr/bin/rsync --progress -avz -e "ssh -i $SSH_FILE" $line root@lf-fileserver:/media/backups/
done < $FILE_FOLDER

