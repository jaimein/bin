#!/bin/bash

echo `echo $1`

$diskini=`echo $1`
echo $diskini
$diskfin=${1#.vmdk}
echo $diskfin

#qemu-img convert -O qcow2 $diskini
