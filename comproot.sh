#!/bin/bash

	### Para que solo root pueda ejecutar el script

	if [ $LOGNAME != "root" ]
	then
	    read -p "Lo siento, este script debe ser ejecutado con privilegios de root."
	    exit 1   
	fi
