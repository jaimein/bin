#!/bin/bash

TOTAL=`cat $1 | wc -l`
for A in `seq 1 $TOTAL` ; do
  a=`head -$A $1 | tail -1 | cut -d ";" -f 1`
    b=`echo -n $a | openssl md5 | cut -d " " -f 2`
    c=`head -$A $1 | tail -1 | cut -d ";" -f 2`
    if [ $b = $c ]
        then
            echo $a."contraseña igual que el nombre" >> ok.tkt
        else
            echo $a."contraseña no es el nombre" >> fail.tkt
    fi
    #read -p "siguiente" op
done
