#!/bin/bash


function titulo()
{
    clear
    echo "****************************************************"
    echo "*   CONFIGURADOR DE DIRECCIONAMIENTO IP ESTÁTICO   *"
    echo "****************************************************"
}

function copiaseg()
{
          
    echo "Realizando copias de seguridad..."
   
    if [ -f /etc/network/interfaces ]
    then
        cp /etc/network/interfaces /etc/network/interfaces.original
        if [ $? -eq 0 ]
        then
            echo "El archivo interfaces ha sido salvaguardado con éxito."
        else
            echo "Error al salvaguardar el archivo interfaces."
        fi
    fi

    if [ -f /etc/resolv.conf ]
    then
        cp /etc/resolv.conf /etc/resolv_original.conf
        if [ $? -eq 0 ]
        then
            echo "El archivo resolv.conf ha sido salvaguardado con éxito."
        else
            echo "Error al salvaguardar el archivo resolv.conf."
        fi
    fi
   
}


function grabar_configuracion()
{

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

    #Modificación de /etc/resolv.conf
    #resolv="/etc/resolv.conf"   
    #echo "#Generado por script configuraip.sh" > $resolv
    #echo "nameserver $5" >> $resolv
    #echo "nameserver $6" >> $resolv

    #reiniciamos los servicios de red para
    #que la nueva configuración tenga efecto
    /etc/init.d/networking stop
	/etc/init.d/networking start

}



#--------------------
# PROGRAMA PRINCIPAL
#--------------------

titulo


if [ $LOGNAME != "root" ]
then
    read -p "Lo siento, este script debe ser ejecutado con privilegios de root."
    exit 1   
fi

#Mostramos los interfaces de red
titulo
echo "Mostrando interfaces de red actuales..."
for nic in `lshw -short -class network | grep eth | tr -s " " | cut -f2 -d" " `
do
    echo "* Interfaz: $nic"
done
echo "-----------------------------------------------------"

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


echo "La interfaz elegida es: $nic_elegida"
read -p "Introduce la nueva dirección ip estática: " ip
read -p "Introduce la nueva máscara de red: " mascara
read -p "Introduce la puerta de enlace: " puerta
read -p "Introduce el DNS 1º: " dns1
read -p "Introduce el DNS 2º: " dns2
echo
read -p "Pulse una tecla para continuar."
titulo

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



