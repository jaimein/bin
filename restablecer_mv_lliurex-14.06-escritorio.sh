#!/bin/bash

cd /home/vlc/pool

### Apagar maquina
virsh shutdown lliurex-14.06-escritorio


### Comprobar estado de la maquina
while [[ $(virsh list --all | grep 'lliurex-14.06-escritorio' | grep 'apagado' | wc -l) = 0 ]];
   do
        echo "Esperando a que la máquina se apague..."
        sleep 5
done

qemu-img create -b lliurex-14.06-escritorio-rebase-*.img -f qcow2 lliurex-14.06-escritorio-incremento.img

virsh start lliurex-14.06-escritorio
