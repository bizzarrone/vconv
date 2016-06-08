rm -rf /scripts
mv -f /CONDIVISA /CONDIVISA-OLDù
mv -f /vconv /vconv-old
mv -f /etc/init.d/rc.local /etc/init.d/rc.local.old
mv -f /var/www/html /var/www/html-old
cd
rm -f install_avconv.sh
wget https://raw.githubusercontent.com/bizzarrone/vconv/master/install_avconv.sh
./install_avconv.sh 
