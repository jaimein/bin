#!/bin/bash

### Script para realizar una configuracion inicial
### /etc/hosts y /etc/network/interfaces

function nombresestaticos() {

	# Ruta del fichero
	ETC_HOSTS=/etc/hosts


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
				TIMESTAMP=$(date "+%Y%m%d_%H%M%S") ### Variable fecha
		        cp /etc/hosts /etc/hosts.original-$TIMESTAMP ###Hace un backup
		        if [ $? -eq 0 ] ###Comprueba si ha funcionado bien
			        then ### Si se ha hecho el backup bien
			            echo "El archivo interfaces ha sido salvaguardado con éxito." ###Mesaje de todo ok
			        else ### Si ha fallado
			            echo "Error al salvaguardar el archivo hosts." ### Mensaje de fail
		        fi
	    fi
	}

	function removehost() {
		
		### Pide parametros
		read -p "Introduzca la ip: " IP
		read -p "Introduzca el hostname: " HOSTNAME
	
	    if [ -n "$(grep $HOSTNAME /etc/hosts)" ] ### Comprueba el hostname
		    then #Si existe
				copiaseg ###LLama a la funcion de la copia de seguridad
		        echo "$HOSTNAME Found in your $ETC_HOSTS, Removing now..."; ### Mensaje de que lo va a eliminar
		        sudo sed -i".bak" "/$HOSTNAME/d" $ETC_HOSTS ###Accion que lo elimina
		    else #Si no existe
				if [ -n "$(grep $IP /etc/hosts)" ] ### Comprueba la IP
					then #Si existe
						copiaseg ###LLama a la funcion de la copia de seguridad
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
				copiaseg ###LLama a la funcion de la copia de seguridad
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

}

function ipestatica () {


	function titulo() { ###Crea el titulo
	    clear
    	echo "****************************************************"
    	echo "*   CONFIGURADOR DE DIRECCIONAMIENTO IP ESTÁTICO   *"
    	echo "****************************************************"
	}

	function copiaseg(){
          
	    echo "Realizando copias de seguridad..."
   
    	if [ -f /etc/network/interfaces ] ###Comprueba si existe el fichero
    		then #Si existe
				TIMESTAMP=$(date "+%Y%m%d_%H%M%S") ### Variable fecha
    		    cp /etc/network/interfaces /etc/network/interfaces.original-$TIMESTAMP ###Hace un backup
    		    if [ $? -eq 0 ] ###Comprueba si se ha realizado corectamente e informa
    			    then
    			        echo "El archivo interfaces ha sido salvaguardado con éxito."
    			    else
    			        echo "Error al salvaguardar el archivo interfaces."
    		    fi
    	fi
  
	}


	function grabar_configuracion(){

	    echo "----------------------------------------------------"
	    echo "La nueva configuración de red introducida es: "
	    echo "Interfaz: $1"
	    echo "Dirección IP: $2"
	    echo "Máscara de red: $3"
	    echo "Puerta de enlace / Gateway: $4"
	    echo "DNS 1º: $5"
	    echo "DNS 2º: $6"
	    echo "----------------------------------------------------"

	    # A partir de aquí abría que reescribir completos los archivos    
	    # de configuración interfaces y resolv.conf
   
   
	    #Modificación de /etc/network/interfaces
	    interfaces="/etc/network/interfaces"
		echo "##modificacion mediante script ip_estatica" > $interfaces
	    echo "auto lo" >> $interfaces
	    echo "iface lo inet loopback" >> $interfaces
		echo "" >> $interfaces
	    echo "auto $1" >> $interfaces
	    echo "iface $1 inet static" >> $interfaces
	    echo "address $2" >> $interfaces
	    echo "mask $3" >> $interfaces
	    echo "gateway $4" >> $interfaces
		echo "dns-nameservers $5 $6" >> $interfaces

	    #reiniciamos los servicios de red para
	    #que la nueva configuración tenga efecto
		read -p "Si en el siguiente paso da fallo es recomendable reiniciar"
	    /etc/init.d/networking stop
		/etc/init.d/networking start
		

	}



	#--------------------
	# PROGRAMA PRINCIPAL
	#--------------------

	titulo ### LLama a la funcion titulo

	#Mostramos los interfaces de red
	titulo
	echo "Mostrando interfaces de red actuales..."
	for nic in `lshw -short -class network | grep eth | tr -s " " | cut -f2 -d" " `
		do
		    echo "* Interfaz: $nic"
	done
	echo "-----------------------------------------------------"

	### Elegimos la interfaz deseada y comprobamos si es correcta
	nic_elegida=""
	while [ "$nic_elegida" == "" ]
		do
	    read -p "Elige la interfaz que deseas configurar: " nic_elegida
	done

	nic_valida=1
	for nic in `lshw -short -class network | grep eth | tr -s " " | cut -f2 -d" " `
		do
	    if [ $nic == $nic_elegida ]
    		then
    		    nic_valida=0
    	fi
	done

	if [ $nic_valida -ne 0 ]
		then
		    echo "Error, la interfaz $nic_elegida no es válida."
		    read -p "Pulsa una tecla para cerrar el script..."
		    exit 1
	fi

	### Mostramos el nombre de la interfaz elegida y pedimos datos

	echo "La interfaz elegida es: $nic_elegida"
	read -p "Introduce la nueva dirección ip estática: " ip
	read -p "Introduce la nueva máscara de red: " mascara
	read -p "Introduce la puerta de enlace: " puerta
	read -p "Introduce el DNS 1º: " dns1
	read -p "Introduce el DNS 2º: " dns2
	echo
	read -p "Pulse una tecla para continuar."

	### Pedimos confirmación para grabar los datos
	respuesta=""
	while [ "$respuesta" == "" ]
		do
		    read -p "Desea grabar estos datos de configuración (S/N): " respuesta
    		case $respuesta in
    		    s|S)copiaseg; grabar_configuracion $nic_elegida $ip $mascara $puerta $dns1 $dns2;            break;;
    		    n|N)echo "Ok, no se modificarán los archivos de configuración"; read; break;;
    		    *) echo "No ha introducido una respuesta válida, vuelva a intentarlo.";;
    		esac
	done

	echo "Fin del script."
	read
	exit 0

}

function selecion() {
	
    clear ### Limpia pantalla
	### Muestra el titulo del script
    echo "****************************************************"
    echo "*           SELECIONE UN CONFIGURADOR              *" 
    echo "****************************************************"
	### Se crea un menu para que se escoja una opcion
	echo "MENU"
	echo "1) nombres estaticos"
	echo "2) ip estatica"
	echo "3) Salir"

	### Se selecciona la opcion deseada
	read -p "Introduzca opcion: " sel

	### Segun la opcion se ejecuta lo que toca
	case $sel in
				1)	nombresestaticos
					exit 1
					;;
				2)  ipestatica
					exit 2
					;;
				3)
					exit 3 ;;
	esac
}

function permisos(){
	### Comprueba si eres root
	if [ $LOGNAME != "root" ]
		then
	 	   read -p "Lo siento, este script debe ser ejecutado con privilegios de root."
		   exit 0  
	fi
	### Llamamos a la funcion para que se ejecute el script
	selecion
}

permisos ### LLamamos a la funcion inicial
