#!/bin/bash

ip=1

while [ $ip -lt 255 ]
	do
		ping -c 1 192.168.0.$ip
		if [ $? = 0 ]
			then 
				echo "La 192.168.0.$ip esta en marcha a las `date`" >> /home/vlc/ipon.txt
			else
				echo "La 192.168.0.$ip esta en apagada a las `date`" >> /home/vlc/ipoff.txt
		fi
	ip=`expr $ip + 1`
done
