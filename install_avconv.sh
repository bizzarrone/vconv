#!/bin/bash
# versione script installazione autoatica: 1.1
# Autore: Luca C.
# Ultima modivica: 27/5/2016

# aggiorno il sistema
apt-get update
apt-get -y install vim screen aptitude samba git  dfc nmon libssl-dev openssh-server  libav-tools  libavcodec54  apache2 php5 make openssh-server
apt-get upgrade -y
locale-gen en_US en_US.UTF-8 it_IT
dpkg-reconfigure locales

# correggi ssh server
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g' /etc/ssh/sshd_config
service ssh restart

# installo n2n
cd /tmp
git clone https://github.com/lukablurr/n2n_v2_fork
cd n2n_v2_fork
sudo make
sudo make install
cd

# preparo il programma
#mkdir /scripts
cd /
git clone https://github.com/bizzarrone/vconv.git
#mv /scripts/vconv/avconvluca.sh /scripts/
touch /vconv/avconv.log
chmod 777 /vconv/parametri.txt

# CREAZIONE Share di rete
mkdir /CONDIVISA
cd /CONDIVISA
mkdir FINAL  intro-IN  intro-OLD  intro-OUT video-IN  video-OLD  video-OUT
chmod -R 777 /CONDIVISA/

# configuro SAMBA
echo  "[CONDIVISA] " >> /etc/samba/smb.conf
echo  " comment = VIDEO " >> /etc/samba/smb.conf
echo  " path = /CONDIVISA" >> /etc/samba/smb.conf
echo  " browseable = yes" >> /etc/samba/smb.conf
echo  " read only = no" >> /etc/samba/smb.conf
echo  " create mask = 0777" >> /etc/samba/smb.conf
echo  " writable = yes" >> /etc/samba/smb.conf
echo  " guest ok = yes" >> /etc/samba/smb.conf

# creare servizio all'avvio
mv /vconv/edge  /etc/init.d/
mv /vconv/vconv /etc/init.d/
update-rc.d edge defaults
update-rc.d edge enable
update-rc.d vconv defaults
update-rc.d vconv enable
update-rc.d apache2 enable 

# installare le webpages
cd /
wget https://github.com/bizzarrone/vconv/raw/master/avconvweb.tar.gz
cd / ; tar xvzf avconvweb.tar.gz
rm /avconvweb.tar.gz
chown -R www-data:www-data  /var/www/html
rm /var/www/html/index.html

# modifico il crontab
echo "00,30 * * * * rm /CONDIVISA/*-OLD/*" >> /var/spool/cron/crontabs/root
