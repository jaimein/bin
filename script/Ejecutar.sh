#!/bin/bash

#####Variables de la impresora
nombre="c280-color"
dirrecion="http://192.168.0.251:631/printers/C280-color"
rutadriver="./../Drivers/KonicaMinolta/C220_C280_C360/Linux/*.ppd"

#####Instalar impresora
sudo lpadmin -p $nombre -v $dirrecion -P $rutadriver -o printer-is-shared=false -E

##### Ejecutar el script para intalar el papercut
bash ./instalar-cliente.sh
