#!/bin/bash



#function obtener {
#$usuario=`awk 'NR=='.$numlin.'' $archivo | cut -f 1`
#$password=`awk 'NR=='.$numlin.'' $archivo | cut -f 2`
#$nombre=`awk 'NR=='.$numlin.'' $archivo | cut -f 5`
#}
archivo=$1

numlin=1


while [ $numlin -le 572 ] 
	do
		usuario=`awk "NR==$numlin" $archivo | cut -f 1`
		password=`awk "NR==$numlin" $archivo | cut -f 2`
		nombre=`awk "NR==$numlin" $archivo | cut -f 5`
		numid=`expr $numlin + 2061`
		echo "dn: cn=$usuario,ou=usuarios,dc=galcala,dc=local
cn: $usuario
gecos: $nombre
gidnumber: 20000
homedirectory: /moviles/$usuario
loginshell: /bin/bash
objectclass: account
objectclass: posixAccount
objectclass: top
uid: $usuario
uidnumber: $numid
userpassword: $password
" >> userldap.ldif
		
		numlin=`expr $numlin + 1`
done
		

