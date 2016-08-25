#!/bin/bash

cd /home/vlc/pool

### Apagar maquina
virsh shutdown ldap-script


### Comprobar estado de la maquina
while [[ $(virsh list --all | grep 'ldap-script' | grep 'apagado' | wc -l) = 0 ]];
   do
        echo "Esperando a que la máquina se apague..."
        sleep 5
done

qemu-img create -b ldap-script-rebase-*.img -f qcow2 ldap-script-incremento.img

virsh start ldap-script
