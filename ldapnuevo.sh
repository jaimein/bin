#!/bin/bash

sudo apt-get update ### Actualiza repositorios

read -p "A continuación se le pedira la contraseña para la administración del ldap" ### Info
sudo apt-get install slapd ldap-utils -y ### Instala el ldap

read -p "Ahora comprobaremos que se ha instalado correctamente"
slapcat ###Muestra la estructura del LDAP


