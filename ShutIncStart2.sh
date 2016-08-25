
#!/bin/bash

### Definición de varibles
# Directorio Actual
CURRENT_DIR="$(pwd)"
# Nombre del img
IMG_FILE="$1"
# Ruta del img
IMG_PATH="$(dirname $IMG_FILE)"
# Nombre de la maquina virtual
NOM_MV="$(basename "$(basename $IMG_FILE .img)" -incremento)"
# Fecha
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
# Rebase anterior
IMG_REM="$(du -h $NOM_MV-rebase-* | cut -f2)"

### Ir al directorio del pool
cd $IMG_PATH


### Crear directorio backup
#mkdir -p ~/backups-pool/$NOM_MV


### Apagar maquina
virsh shutdown $NOM_MV


### Comprobar estado de la maquina
while [[ $(virsh list --all | grep $NOM_MV | grep 'apagado' | wc -l) = 0 ]];
   do
        echo "Esperando a que la máquina se apague..."
        sleep 5
done


### 



### Contamos cuantos incrementos tenemos

NOM_REB="${NOM_MV}-rebase-${TIMESTAMP}"
##NUM_REB=`$(ls -l ${NOM_MV}-incremento-*.img | wc -l)`


#if [ $(ls -l ${NOM_MV}-incremento-*.img | wc -l) -gt 1 ]
if [ $(ls -l ${NOM_MV}-incremento.img | wc -l) -gt 0 ]
	then
		###Rebase
		qemu-img convert -p $NOM_MV-incremento.img -O qcow2 $NOM_REB.img
		#ln -f $NOM_REB.img ~/backups-pool/$NOM_MV/$NOM_REB.img
		chmod o=rw $NOM_REB.img
		#chmod o=rw ~/backups-pool/$NOM_MV/$NOM_REB.img
		#rm -f ${NOM_MV}-incremento-*
		
	else
		echo "No hay más de 1 incrementos"
fi

### Definición de la variable del nombre del incremento
NOM_INC="${NOM_MV}-incremento"

### Eliminar incremento
rm $NOM_INC.img

### Crear incremento
qemu-img create -b $NOM_REB.img -f qcow2 $NOM_INC.img

### Damos permisos
chmod o=rw $NOM_INC.img

### Arrancamos la máquina
virsh start $NOM_MV

echo "Eliminando el rebase anterior"
rm -v $IMG_REM
