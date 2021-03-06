
#!/bin/bash

## Este script generará multiples scripts que contendran los comandos para tener
## todos los servidores con sus servicios y configuraciones.

## FUNCIONES ###################################################################
get_ip(){
	NETPART=`echo $1 | cut -d'.' -f1-3`
	echo "$NETPART.$2"
}

pideIPZ(){
    # $1 sera de donde es dicha IP (ej: "de la red LAN") y $2 sera la IP ejemplo
    zenity --entry --title="IP $1" --text="Dirección IP $1:" --entry-text "ej. '$2'"
}

pideHostZ(){
    # $1 es el nombre de la 'utilidad' del servidor (ej: Apache2, DNS) y $2 el nombre real de dicha maquina (apache-server, dns-server)
    zenity --entry --title="Hostname del servidor $1" --text="Hostname del servidor $1:" --entry-text "$2"
}

pide4octZ(){
    # $1 sera de donde es dicho octeto (ej: "del servidor iptables") y $2 sera el numero ejemplo
    zenity --entry --title="Cuarto octeto de la dirección IP $1" --text="Cuarto octeto de la dirección IP $1:" --entry-text "ej. '$2'"
}

pideDomZ(){
    # $1 sera de donde es el dominio (DNS, Samba, LDAP) y $2 el nombre ejemplo
    zenity --entry --title="Nombre del dominio $1" --text="Nombre del dominio $1: " --entry-text "ej. '$2'"
}
################################################################################

## PARAMETROS ##################################################################

LANNET=$(pideIPZ "de la red" "192.168.100.0")

LDAPHOSTNAME=$(pideHostZ "LDAP" "Sldap-pc00")
LDAPSRVIP=$(pide4octZ "del servidor LDAP" "5")
LDAPSRVIP=`get_ip $LANNET $LDAPSRVIP`
DOMAINNAME=$(pideDomZ "LDAP" "s04-pc00")
SMBDOMAIN=$(pideDomZ "Samba" "S04-PC00")
################################################################################

## SERVIDOR IPTABLES ###########################################################

################################################################################

## SERVIDOR DNS ################################################################

################################################################################

## SERVIDOR WEB ################################################################

################################################################################

## SERVIDOR LDAP ###############################################################
cat <<LDAPEOF > ldap-server-setup.sh
#!/bin/bash
sudo apt-get update
sudo apt-get install slapd ldap-utils samba samba-doc libpam-smbpass smbclient smbldap-tools winbind
sudo dpkg-reconfigure slapd
sudo slapcat
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/cosine.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/inetorgperson.ldif
sudo -u root bash <<'EOF'
zcat /usr/share/doc/samba-doc/examples/LDAP/samba.schema.gz > /etc/ldap/schema/samba.schema
cat <<'EOF2' >samba.conf
include /etc/ldap/schema/core.schema
include /etc/ldap/schema/cosine.schema
include /etc/ldap/schema/nis.schema
include /etc/ldap/schema/inetorgperson.schema
include /etc/ldap/schema/samba.schema
EOF2
mkdir /tmp/slapd.d
slaptest -f samba.conf -F /tmp/slapd.d/
cp "/tmp/slapd.d/cn=config/cn=schema/cn={4}samba.ldif" "/etc/ldap/slapd.d/cn=config/cn=schema"
chown openldap:openldap '/etc/ldap/slapd.d/cn=config/cn=schema/cn={4}samba.ldif'
/etc/init.d/slapd stop
/etc/init.d/slapd start
ldapsearch -LLLQY EXTERNAL -H ldapi:/// -b cn=schema,cn=config "(objectClass=olcSchemaConfig)" dn
EOF
sudo cp /etc/samba/smb.conf smb.conf.old
sudo bash -c "cat <<'EOF' > /etc/samba/smb.conf
;
; /etc/smb.conf
;
[global]
# Nombre de dominio
   workgroup = $DOMAINNAME
# Nombre de servidor para ser visto por los PCs de Windows.
   netbios name = ${DOMAINNAME}-samba
# Es un PDC
   domain logons = yes
   domain master = yes
# Es un Servidor WINS
   wins support = yes
   obey pam restrictions = yes
   dns proxy = no
   os level = 35
   log file = /var/log/samba/log.%m
   max log size = 1000
   syslog = 0
   panic action = /usr/share/samba/panic-action %d
   pam password change = yes
# Permitir a los ususarios de Windows cambiar su password con Ctrl-Alt-Del
   unix password sync = no
   ldap passwd sync = yes
# Imprimir desde los PCs vía CUPS
   load printers = yes
   printing = cups
   printcap name = cups
# Use LDAP for Samba user accounts and groups ..
   passdb backend = ldapsam:ldap://localhost
# This must match init.ldif ...
   ldap suffix = dc=${DOMAINNAME},dc=local
# The password for cn=admin MUST be stored in /etc/samba/secrets.tdb
# This is done by running 'sudo smbpasswd -w'
   ldap admin dn = cn=admin,dc=${DOMAINNAME},dc=local
# 4 OUs that Samba uses when creating user accounts , computer accounts , etc.
# (Because we are using smbldap-tools, call them 'Users','Computers',etc.)
   ldap machine suffix = ou=Computers
   ldap user suffix = ou=Users
   ldap group suffix = ou=Groups
   ldap idmap suffix = ou=Idmap
# Samba and LDAP server are on the same server in this example.
   ldap ssl = no
# Scripts for Samba to use if it creates users, groups, etc.
   add user script = /usr/sbin/smbldap-useradd -m '%u'
   delete user script = /usr/sbin/smbldap-userdel '%u'
   add group script = /usr/sbin/smbldap-group-add -p '%g'
   delete group script = /usr/sbin/smbldap-groupdel '%g'
   add user to group script = /usr/sbin/smbldap-groupmod -m '%u''%g'
   delete user from group script = /usr/sbin/smbldap-groupmod -x '%u''%g'
   set primary group script = /usr/sbin/smbldap-usermod -g '%g''%u'
# Script that Samba users when a PC joins the domain ..
# (when changing ' Computer Properties' on the PC)
   add machine script = /usr/smb/smbldap-useradd -w '%u'
# Values used when a new user is created ..
# (Note: '%L' does not work properly with smbldap-tools 0.9.4-1)
# Opción 1 – Sin perfil móvil, cuando inicie sesión un usuario, se creará el “home” en
# cada equipo local.
   logon drive =
   logon home =
   logon path =
   logon script = allusers.bat
#
# This is required for Windows XP client ..
   server signing = auto
   server schannel = auto
[homes]
   comment = Home Directories
   valid users = %S
   read only = no
   browseable = no
[netlogon]
   comment = Network Logon Service
   path = /var/lib/samba/netlogon
   admin users = root
   guest ok = yes
   browsable = no
   logon script = allusers.bat
[Profiles]
   comment = Roaming Profile Share
   # would probably change this to elsewhere in a production system ...
   path = /var/lib/samba/profiles
   read only = no
   profile acls = yes
   browseable = no
[printers]
   comment = All Printers
   path = /var/spool/samba
   use client driver = yes
   create mask = 0600
   guest ok = yes
   printable = yes
   browseable = no
   public = yes
   writable = yes
   admin users = root
   write list = root
[print$]
   comment = Printer Drivers Share
   path = /var/lib/samba/printers
   write list = root
   create mask = 0664
   directory mask = 0775
   admin users = root
[shared]
   writeable = yes
   path = /var/lib/samba/shared
   public = yes
   browseable = yes
[archive]
   path = /exports/archive
   browseable = yes
   create mask = 755
   directory mask = 755
   read only = no
EOF"
testparm
read -p "Lee y comprueba el testparm. Despues dale a ENTER"
sudo service smbd restart
sudo service nmbd restart
sudo service winbind restart
sudo smbpasswd -W
sudo smbclient -L localhost
sudo mkdir -v -m 777 /var/lib/samba/profiles
sudo mkdir -v -p -m 777 /var/lib/samba/netlogon
sudo cp /usr/share/doc/smbldap-tools/examples/smbldap.conf.gz /etc/smbldap-tools/
sudo cp /usr/share/doc/smbldap-tools/examples/smbldap_bind.conf /etc/smbldap-tools/
sudo gzip -d /etc/smbldap-tools/smbldap.conf.gz
LocalSID=\`sudo net getlocalsid | cut -d':' -f2 | tr -d ' '\`
sudo sed -i -e "s/SID=\".*\"/SID=\"\$LocalSID\"/g" \\
	-e "s/sambaDomain=\".*\"/sambaDomain=\"$SMBDOMAIN\"/g" \\
	-e "s/slaveLDAP=/#slaveLDAP=/g" \\
	-e "s/masterLDAP=\".*\"/masterLDAP=\"ldap:\/\/$LDAPHOSTNAME.$DOMAINNAME.local\/\"/g" \\
	-e "s/ldapTLS=\"1\"/ldapTLS=\"0\"/g" \\
	-e "s/verify=\"require\"/verify=\"none\"/g" \\
	-e "s/clientcert=\".*\"/clientcert=\"\/etc\/smbldap-tools\/smbldap-tools.$DOMAINNAME.local.pem\"/g" \\
	-e "s/clientkey=\".*\"/clientkey=\"\/etc\/smbldap-tools\/smbldap-tools.$DOMAINNAME.local.key\"/g" \\
	-e "s/suffix=\".*\"/suffix=\"dc=$DOMAINNAME,dc=local\"/g" \\
	-e "s/userSmbHome=\".*\"/userSmbHome=\""'\\\\\\\\'"$SMBDOMAIN"'\\\\%U'"\"/g" \\
	-e "s/userProfile=\".*\"/userProfile=\""'\\\\\\\\'"$SMBDOMAIN"'\\\\profiles\\\\%U'"\"/g" \\
	-e "s/userHomeDrive=\".*\"/userHomeDrive=\"H:\"/g" \\
	-e "s/mailDomain=\".*\"/mailDomain=\"$DOMAINNAME.local\"/g" \\
	/etc/smbldap-tools/smbldap.conf
read -s -p "Contraseña de root de SAMBA (ej. 'ausias'): " SMBROOTPASS; echo
sudo sed -i -e "s/slaveDN=\"/#slaveSID=\"/g" \\
	-e "s/slavePw=\"/#slavePw=\"/g" \\
	-e "s/masterDN=\".*\"/masterDN=\"cn=admin,dc=$DOMAINNAME,dc=local\"/g" \\
	-e "s/masterPw=\".*\"/masterPw=\"\$SMBROOTPASS\"/g" \\
	/etc/smbldap-tools/smbldap_bind.conf
sudo smbldap-populate
sudo service smbd restart
sudo service nmbd restart
sudo service winbind restart
sudo service slapd restart
read -p "Se va a instalar libnss-ldap, lo siguiente que debes escribir en orden es:
    ldap://$LDAPSRVIP
    dc=$DOMAINNAME,dc=local
    3
    Sí
    No
    cn=admin,dc=$DOMAINNAME,dc=local
    ******"
sudo apt-get install libnss-ldap
read -p "Ahora se reconfigurará, lo mismo pero añadiendo:
    debconf: Sí
    Local crypt: crypt"
sudo dpkg-reconfigure ldap-auth-config
sudo auth-client-config -t nss -p lac_ldap
read -p "Selecciona las siguientes:
    [*] Unix authentication                                                                                                                                  │
    [*] Winbind NT/Active Directory authentication                                                                                                           │
    [*] LDAP Authentication"
sudo pam-auth-update
read -p "Comprueba los siguientes grupos..."
sudo getent group | less
sudo apt-get install apache2 ldap-account-manager
sudo service apache2 restart
read -p "A partir de aquí configura el LDAP mediante el LDAP Manager"
sudo bash -c "cat <<'EOF' > /var/lib/samba/netlogon/logon.bat
@echo off
net time \\\\\\\\$LDAPSRVIP /set /yes
net use z: \\\\\\\\$LDAPSRVIP\datosEnServidor
EOF"
sudo chown root:root /var/lib/samba/netlogon/logon.bat
sudo chmod 755 /var/lib/samba/netlogon/logon.bat
sudo mkdir /datosDeUsuariosLDAP
sudo chown nobody:nogroup /datosDeUsuariosLDAP
sudo chmod 777 /datosDeUsuariosLDAP
sudo bash -c "cat <<'EOF' > /datosDeUsuariosLDAP/creaCarpetaDeUsuarioLDAP.sh
#!/bin/bash
if [ ! -d /datosDeUsuariosLDAP/\\\$1 ]
then
    mkdir /datosDeUsuariosLDAP/\\\$1
    chown \\\$1:\\\$2 /datosDeUsuariosLDAP/\\\$1
fi
EOF"
sudo chown nobody:nogroup /datosDeUsuariosLDAP/creaCarpetaDeUsuarioLDAP.sh
sudo chmod 755 /datosDeUsuariosLDAP/creaCarpetaDeUsuarioLDAP.sh
sudo sed -i -e '59 s/\(logon drive =\).*/\1 Z\:/g' \\
	-e '62 s/\(logon script =\).*/\1 logon.bat/g' \\
	-e '78 s/\(logon script =\).*/\1 logon.bat/g' \\
	/etc/samba/smb.conf
sudo bash -c "cat <<'EOF' >> /etc/samba/smb.conf
[datosEnServidor]
   preexec = /datosDeUsuariosLDAP/creaCarpetaDeUsuarioLDAP.sh %U %G
   path = /datosDeUsuariosLDAP/%U
   browseable = yes
   create mask = 775
   directory mask = 775
   read only = no
EOF"
sudo apt-get install nfs-kernel-server
sudo bash -c "cat <<'EOF' >> /etc/hosts.allow
portmap: $LANNET/24
nfs: $LANNET/24
EOF"
sudo bash -c "echo \"/datosDeUsuariosLDAP $LANNET/24(rw,sync,no_root_squash,no_subtree_check)\" >> /etc/exports"
sudo service nfs-kernel-server restart
LDAPEOF

################################################################################

## SERVIDOR MYSQL ##############################################################

################################################################################
