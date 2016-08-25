#!/bin/bash

fecha=`date +"%Y%m%d_%H%M%S"`
pool="/home/vlc/pool/"


function irPool {
	cd $pool
}

function nombreDisco {

	d="`zenity --entry \
		--title="Crear disco duro" \
		--text="Escriba el nombre del disco duro:" \
		--entry-text "Nombre del disco duro"`"

	if [ "$d" = "" ] | [ "$d" = "Nombre del disco duro" ]
	then
		echo "No ha especificado ningún nombre"
		zenity --error \
			--text="No ha especificado ningun nombre"
		nombreDisco
	else
		echo "falla"
		tamanoDisco
	fi
	
}

function tamanoDisco {

###################
tamMax="`df -h | grep "^/" | sed 's/ * /,/g' | cut -d "," -f 4 | sed 's/.$//g'`"
###################


	tamDisco="`zenity --scale \
		--title='Crear disco duro' \
		--value='10' \
		--max-value=$tamMax \
		--text='Escriba el tamaño del disco duro en GB:' \
		 `"
		es_numero='^-?[0-9]+([.][0-9]+)?$'
	if [ ! "$tamDisco" = "" ] | [ ! "$tamDisco" = $es_numero ]
		then
			echo "esta bien introducido"
			qemu-img create -f qcow2 "$d"-rebase-"$fecha".img "$tamDisco"G
			qemu-img create -b "$d"-rebase-"$fecha".img -f qcow2 "$d"-incremento.img
			
		else
				echo "No ha introducido un tamaño valido"
				zenity --error \
					--text="No ha introducido un tamaño valido"
				tamañoDisco
		fi
}

function instalarMV {
	nameMV=$d
	ramMV=512
	vcupsMV=1
	typeOSMV="linux"
	cdromMV="/home/vlc/Descargas/ubuntu-15.10-desktop-i386.iso"

	virt-install --connect=qemu:///system --name=$nameMV --ram=$ramMV --vcpus=$vcupsMV --check-cpu --os-type=$typeOSMV --vnc --accelerate --disk path=$d"-incremento.img" --cdrom=$cdromMV --network=bridge:br0
}

irPool
nombreDisco
instalarMV
