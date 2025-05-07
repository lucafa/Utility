#!/bin/bash

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

while true;
do
echo -e "Insert subnet address:"
read SUBNET
if valid_ip $SUBNET;
then
        echo -e "Select CIDR value: \n 1) /8 \n 2) /16"
        read CIDR
        case $CIDR in

                1)
                IP=`echo $SUBNET | awk -F"." '{print $1"."$2"."$3"."}'`
                for i in `seq 1 255`
                        do
                                MAC=`arping -I eth0 -c 1 $IP$i | grep Unicast | awk -F "[" '{print $2}'  | awk -F "]" '{print $1}'`
                                echo $IP$i "-->" $MAC 
                        done
                ;;
                2)
                IP=`echo $SUBNET | awk -F"." '{print $1"."$2"."}'`
                for i in `seq 0 255`
                     do
                        for l in `seq 1 255`
                             do
                                 MAC=`arping -I eth0 -c 1 $IP$i"."$l | grep Unicast | awk -F "[" '{print $2}'  | awk -F "]" '{print $1}'`
                                 echo $IP$i"."$l "-->" $MAC
                             done
                     done
                ;;
                *)
                echo -e "\nWrong button\n"
                ;;
        esac
break

else stat=1; fi
echo $stat
done
