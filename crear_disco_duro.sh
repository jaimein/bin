#!/bin/bash

#!/bin/sh

fecha=`date +"%Y%m%d_%H%M%S"`

d="`zenity --entry \
--title="Crear disco duro" \
--text="Escriba el nombre del disco duro:" \
--entry-text "Nombre del disco duro"`"

if [ "$d" = "" ] | [ "$d" = "Nombre del disco duro" ]
	then
		echo "No ha especificado ningún nombre"
	else
		s="`zenity --entry \
		--title="Crear disco duro" \
		--text="Escriba el tamaño del disco duro en GB:" \
		--entry-text "Introduce Tamaño"`"
		es_numero='^-?[0-9]+([.][0-9]+)?$'
		if [ ! "$s" = "" ] | [ ! "$s" = $es_numero ]
			then
				echo "esta bien introducido"
				qemu-img create -f qcow2 "$d"-rebase-"$fecha".img "$s"G
				qemu-img create -b "$d"-rebase-"$fecha".img -f qcow2 "$d"-incremento.img
			else
				echo "No ha introducido un tamaño valido"
		fi
fi
		


