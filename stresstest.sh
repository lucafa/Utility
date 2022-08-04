#!/bin/bash
URL="http://localhost:8081"
#URL="http://testtt.xxxx"
HOST="testtt.xxx"
LOGIN_API="/api/v1/auth/login"
API_1="/api/v1/wallet"
API_2="/api/v1/general_data"
API_3="/api/v1/shop"
#There are 3 values to change when change the token creation uuid: 1 in for cicle of token creation, 1 in for cicle of token extraction and 1 in RANDOM_TOKEN assignation
#Clean folder
rm ./*.txt


#Token creation
for i in {10..26}
do
	curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 21' -H 'requirestoken: true' -H "host: $HOST" -H 'Connection: close' --data-binary 'uuid=aaaaaaaaaaaaaa'$i  "$URL$LOGIN_API" >> $i.txt
done

#Token extraction

for i in {10..26}
do
	cat $i.txt | grep token  | jq  '.token."access_token"'  | awk -F'"' '{print $2}' >> token_$i.txt
done

#Function to create random requests 

while true
do
	RANDOM_API=`echo $((1 + $RANDOM % 10))`
	RANDOM_TOKEN=`shuf -i 10-26 -n1`
	TOKEN=`cat token_$RANDOM_TOKEN.txt`
	#API=`cat api_$RANDOM_API`
	

case $RANDOM_API in

	1)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 0'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close'  "$URL/api/v1/wallet" 
			;;
	
	2)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 0'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close'  "$URL/api/v1/general_data"
			;;
	3)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 0'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close'  "$URL/api/v1/shop"
			;;	
        
	4)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 12'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'jackpot_id=2'  "$URL/api/v1/next_prev_draw"
			;;
	5)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 12'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'jackpot_id=1'  "$URL/api/v1/next_prev_draw"
			;;
	6)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 13'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'product_id=11'  "$URL/api/v1/submit_order"
			;;
	7)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 12'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'jackpot_id=1'  "$URL/api/v1/divisions"
			;;

	8)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 19'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'jackpot_id=1&page=1'  "$URL/api/v1/my_grids"
			;;
	9)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 19'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'jackpot_id=2&page=1'  "$URL/api/v1/my_grids"
			;;
	10)
			curl -i -s -k -X 'POST' -H 'user-agent: Dart/2.17 (dart:io)' -H 'content-type: application/x-www-form-urlencoded;charset=utf-8' -H 'Accept-Encoding: gzip, deflate' -H 'Content-Length: 6'  -H "authorization: Bearer $TOKEN" -H "host: $HOST" -H 'Connection: close' --data-binary 'page=1'  "$URL/api/v1/my_prize"
			;;
		
		esac
	#sleep 1
done
