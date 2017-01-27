#!/bin/bash

if [ `egrep -c '(vmx|svm)' /proc/cpuinfo` = 0 ]
	then
		echo "Su hardware no soporta virtualizacion"
	else
		echo "su hardware soporta virtualizacion"
		echo "Se procedera ha instalar qemu-kvm"
		sudo apt-get update && sudo apt-get install qemu-kvm  libvirt-bin ubuntu-vm-builder bridge-utils virt-manager
		echo "ahora hay que reiniciar"
fi
