VCONV
=====
Convert automatically avi and mov files into .mp4 (h264) copied into a samba share.

To install:
-----------
As root user (ie: sudo su - ) launch following commands:

<pre>
  cd ~
  wget https://raw.githubusercontent.com/bizzarrone/vconv/master/install_avconv.sh
  sh install_avconv.sh
  reboot
</pre>

In case of updating:
-------------------
As root user (ie: sudo su - ) launch following commands:

<pre>
  cd ~
  rm -f update_avconv.sh
  wget https://raw.githubusercontent.com/bizzarrone/vconv/master/update_avconv.sh
  sh update_avconv.sh
  reboot
</pre>

