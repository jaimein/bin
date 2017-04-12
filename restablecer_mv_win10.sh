#!/bin/bash

cd /home/vlc/pool

### Apagar maquina
virsh shutdown Win10


### Comprobar estado de la maquina
while [[ $(virsh list --all | grep 'Win10' | grep 'apagado' | wc -l) = 0 ]];
   do
        echo "Esperando a que la máquina se apague..."
        sleep 5
done

qemu-img create -b Win10-rebase-*.img -f qcow2 Win10-incremento.img

virsh start Win10
