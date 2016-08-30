#!/bin/bash

function comroot() {	
	### Para que solo root pueda ejecutar el script

	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de root."
	    exit 1   
	fi
}

function instalar () {

### Explicacion
	read -p "Durante el proceso, se activa un asistente que nos permite configurar el comportamiento de ldap-auth-config."
	read -p "En el primer paso, nos solicita la dirección URi del servidor LDAP. En nuestro caso, escribiremos la dirección IP del servidor y sustituiremos el protocolo ldapi:/// por ldap://."
	read -p "En el siguiente paso, debemos indicar el nombre global único (Distinguished Name – DN). Inicialmente aparece en valor dc=example,dc=net pero nosotros lo sustituiremos por dc=jaime,dc=local, por ejemplo."
	read -p "A continuación, el asistente nos pide la versión del protocolo LDAP que estamos utilizando. Selecionaremos la versión 3."
	read -p "A continuación, indicaremos si las utilidades que utilicen PAM deberán comportarse del mismo modo que cuando cambiamos contraseñas locales. Esto hará que las contraseñas se guarden en un archivo independiente que sólo podrá ser leído por el superusuario. Selecionaremos que si."
	read -p "Después, el sistema nos pregunta si queremos que sea necesario identificarse para realizar consultas en la base de datos de LDAP. Selecionaremos que no."
	read -p "Ya sólo nos queda indicar el nombre de la cuenta LDAP que tendrá privilegios para realizar cambios en las contraseñas. En nuestro caso cn=admin,dc=jaime,dc=local"
	read -p "Y por ultimo, nos pedira la contraseña"

### Instalacion
	sudo apt-get install libnss-ldap libpam-ldap ldap-utils -y
}
