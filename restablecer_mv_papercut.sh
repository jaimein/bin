#!/bin/bash

cd /home/vlc/pool

### Apagar maquina
virsh shutdown Ubuntu-papercut


### Comprobar estado de la maquina
while [[ $(virsh list --all | grep 'Ubuntu-papercut' | grep 'apagado' | wc -l) = 0 ]];
   do
        echo "Esperando a que la máquina se apague..."
        sleep 5
done

qemu-img create -b Ubuntu-papercut-rebase-*.img -f qcow2 Ubuntu-papercut-incremento.img

virsh start Ubuntu-papercut
