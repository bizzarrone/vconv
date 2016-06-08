#!/bin/bash
# Script per aggiornamnto programma avconv

rm -rf /scripts
mv -f /CONDIVISA /CONDIVISA-OLD
rm -rf /vconv 
mv -f /etc/init.d/rc.local /etc/init.d/rc.local.old
rm -rf /var/www/html 
cd
rm -f install_avconv.sh*
wget https://raw.githubusercontent.com/bizzarrone/vconv/master/install_avconv.sh
sh install_avconv.sh 
