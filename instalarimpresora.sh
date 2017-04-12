#!/bin/sh

nombre=`zenity --entry \
--title="Instalar impresora" \
--text="Enter name of new profile:" \
--entry-text "NewProfile"`


sudo lpadmin -p $nombre -v $dirrecion -P $rutadriver -o printer-is-shared=false

