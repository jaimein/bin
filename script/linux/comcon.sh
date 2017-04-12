#!/bin/bash
sleep 10

###variables de servidor
ip="192.168.0.251"

###funcion comprobar conectividad
isconnect() {
	nc -w1 -z $ip 9191
}

###Ejecutar cliente
f1() {
	/opt/.linux/pc-client-linux.sh &
	exit 0
}

###Bucle con espera de 30 segundos
until isconnect; do
sleep 30
done

f1

