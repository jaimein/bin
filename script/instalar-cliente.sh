#!/bin/bash

###Funcion de instalar cliente
instalarclient() {
	echo "Se va a instalar el cliente"
    sudo cp -r ./linux /opt/.linux
    sudo chmod -R 777 /opt/.linux
    sudo cp impresion.sh /etc/profile.d/impresion.sh
    sudo chmod 755 /etc/profile.d/impresion.sh
}

###Para ejecutar el cliente
ejecutar(){
	echo "Se va a ejecutar el cliente"
    sh /etc/profile.d/impresion.sh &
}

### funcion para comprobar si hay otra y eliminarla
cominst(){
	if [ -d /opt/.linux ]
		then
			echo "Hay otra instalacion ya realizada de el cliente papercut"
			read -p "¿Desea eliminar la anterior antes de proseguir? s/n Si no la elimina puede causar problemas " resp
			if [ $resp == 's' ] || [ $resp == 'S' ]
				then
					sudo rm -rf /opt/.linux
			fi
	fi
}


### Programa Principal
cominst
instalarclient
ejecutar
