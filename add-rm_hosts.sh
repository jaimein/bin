#!/bin/bash

# PATH TO YOUR HOSTS FILE
ETC_HOSTS=/etc/hosts

# DEFAULT IP FOR HOSTNAME
#IP="127.0.0.1"

# Hostname to add/remove.
#HOSTNAME=$1




function titulonomest() {

    clear ### Limpia pantalla
	### Muestra el titulo del script
    echo "****************************************************"
    echo "*        CONFIGURADOR DE NOMBRES ESTÁTICO          *"
    echo "****************************************************"
	### Se crea un menu para que se escoja una opcion
	echo "MENU"
	echo "1) Añadir host"
	echo "2) Eliminar host"
	echo "3) Salir"

	### Se selecciona la opcion deseada
	read -p "Introduzca opcion: " opt

	### Segun la opcion se ejecuta lo que toca
	case $opt in
				1)	addhost
					exit 1
					;;
				2)  removehost
					exit 2
					;;
				3)
					exit 3 ;;
	esac
}

function copiaseg() {
          
    echo "Realizando copias de seguridad..."
   
    if [ -f /etc/hosts ] ###Comprueba si existe el fichero
    then ### Si existe
        cp /etc/hosts /etc/hosts.original ###Hace un backup
        if [ $? -eq 0 ] ###Comprueba si ha funcionado bien
        then ### Si se ha hecho el backup bien
            echo "El archivo interfaces ha sido salvaguardado con éxito." ###Mesaje de todo ok
        else ### Si ha fallado
            echo "Error al salvaguardar el archivo interfaces." ### Mensaje de fail
        fi
    fi
}

function removehost() {

	### Pide parametros
	read -p "Introduzca la ip: " IP
	read -p "Introduzca el hostname: " HOSTNAME

	
    if [ -n "$(grep $HOSTNAME /etc/hosts)" ] ### Comprueba el hostname
    then #Si existe
        echo "$HOSTNAME Found in your $ETC_HOSTS, Removing now..."; ### Mensaje de que lo va a eliminar
        sudo sed -i".bak" "/$HOSTNAME/d" $ETC_HOSTS ###Accion que lo elimina
    else #Si no existe
		if [ -n "$(grep $IP /etc/hosts)" ] ### Comprueba la IP
			then #Si existe
				echo "$IP Found in your $ETC_HOSTS, Removing now..."; ### Mensaje de que lo va a eliminar
       			sudo sed -i".bak" "/$IP/d" $ETC_HOSTS ###Accion que lo elimina
			else #Si no existe
        		echo "$HOSTNAME o $IP was not found in your $ETC_HOSTS"; ### Mensaje not found
		fi

    fi
}

function addhost() {

	### Pide parametros
	read -p "Introduzca la ip: " IP
	read -p "Introduzca el hostname: " HOSTNAME
	read -p "Introduzca un alias: " ALIAS
	read -p "Introduzca un dominio: " DOM
    
	### Da formato a los datos para el archivo
    HOSTS_LINE="$IP\t$HOSTNAME.$DOM\t$HOSTNAME\t$ALIAS"

    if [ -n "$(grep $HOSTNAME /etc/hosts)" ] || [ -n "$(grep $IP /etc/hosts)" ] ### Comprueba si existe alguno de los dos parametros
        then ### Si existe alguno de los dos informa
            echo "$HOSTNAME o $IP already exists : $(grep $HOSTNAME $ETC_HOSTS)"
        else ### Sino existe
            echo "Adding $HOSTNAME to your $ETC_HOSTS"; ### Informa de lo que va ha hacer
            sudo -- sh -c -e "echo '$HOSTS_LINE' >> /etc/hosts"; ### Lo añade a /etc/hosts

            if [ -n "$(grep $HOSTNAME /etc/hosts)" ] ###Comprueba si esta añadido
                then ### Si lo est informa de todo ok
                    echo "$HOSTNAME was added succesfully \n $(grep $HOSTNAME /etc/hosts)";
                else ### Si no esta mensaje de fail
                    echo "Failed to Add $HOSTNAME, Try again!";
            fi
	fi
}

titulonomest


