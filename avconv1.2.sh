#!/bin/bash

version="1.2"
# CHANGELOG
# 2015-12-07 v1.2
# rinomina cartelle: IN OUT OLD
# ---------------------------
# 2015-12-07 v1.1
# rinoma del file forzato
# ---------------------------
# rinoma del file forzato
# to do 
# possibilità di cambiare rate e codifica. da pagian web php. scrive poi su file i valori
# echo $A | cut -f 2 -d "#"  
# delimitare il  nme gara da #gara#  in tale modo
# cosi non ci sonoproblemi in lunghezza nome fantino
# cheidere se oltre al bitrate va modificato anche altro
# mettere n2n sul server
#if [ -f /var/log/messages ]
#  then
#    echo "/var/log/messages exists."
#fi

function codifica
{
 # options: ultrafast, superfast, veryfast, faster, fast, medium (default), slow and veryslow
 preset=medium
 profile=baseline
 bitrate=5000k
 maxbitrate=10000k
 rate=30
 avconv -i $IN/"$nomefile" -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $bitrate -acodec aac -b:a 128k -strict experimental  -threads 0   $OUT/`basename "$nomefile" $estensione`.ts -y
}

# =======================================================================
while true
do

 echo "# Controllo INTRO"
 intro_IN="/CONDIVISA/intro-IN"
 intro_OUT="/CONDIVISA/intro-OUT"
 intro_OLD="/CONDIVISA/intro-OLD"
 OUT_INTRO=OUT
 cd $intro_IN
 # rinomino i file eliminando spazi (se in uso non ci sono problemi, samba continua a scriverci)
 find -name "* *" -type f | rename 's/ /_/g'

 for f  in  *.avi 
 do
  nomefile=`basename $f` 
  #echo "nomefile $nomefile"
  if [ "$nomefile" != "*.avi" ]
  then 
   #echo "# nomefile : $nomefile"
   #nomeparzialefile=`echo $nomefile | cut -f 1 -d " "`
   #echo "# nomeparzialefile : $nomeparzialefile"
   smbstatus | grep -i ".avi" > /dev/null
   if [ $? = "1"  ] 
   then
 	echo "#  File INTRO pronto per elaborazione   : $nomefile"
        echo "#  Elaborazione INTRO $nomefile"
	estensione=".avi"
 	codifica
 	echo "#  Sposto file INTRO in elaborati"
	mv -v -f $nomefile $intro_OLD/$nomefile
   else
 	echo "#  Copia in corso per il file. File non pronto per elaborazione. Attendo Termine.  :  $nomefile  "
   fi
  fi
 done

############## ORIG ###################################################

 echo "# Controllo video ORIGINALI"
 video_IN="/CONDIVISA/video-IN"
 video_OUT="/CONDIVISA/video-OUT"
 video_OLD="/CONDIVISA/video-OLD"
 FINAL="/CONDIVISA/FINAL"
 cd $video_IN
 # rinomino i file eliminando spazi (se in uso non ci sono problemi, samba continua a scriverci)
 find -name "* *" -type f | rename 's/ /_/g'
 for f  in  *.MOV
 do
  nomefile=`basename $f`
  if [ "$nomefile" != "*.MOV" ]
  then
   smbstatus | grep -i ".mov" > /dev/null
   if [ $? = "1"  ]
    then
 	find -name "* *" -type f | rename 's/ /_/g'
        echo "#  File ORIG  pronto per elaborazione   : $nomefile"
        echo "#  Elaborazione ORIG  $nomefile"
	estensione=".MOV"
	KEY_INTRO=`echo $nomefile | cut -f 2 -d "."`
	echo "# Key intro da cercare: $KEY_INTRO"
	#OUT_INTRO="/CONDIVISA/INTRO-completed"
	INTRO_DA_AGGANCIARE=`ls $intro_OUT/*$KEY_INTRO*`
        echo "# Intro da agganciare : $INTRO_DA_AGGANCIARE"

	# se non trova INTRO da agganciare da errore ed esce
	if [ -f $intro_OUT/*$KEY_INTRO* ]
  	then
         echo "# INTRO trovato per questo ORIGINAL"	
	 codifica
         echo "#  Sposto ORIG file in elaborati"
         mv -f -v $nomefile $video_OLD/$nomefile

	 ORIG_DA_AGGANCIARE=$video_OUT/`basename "$nomefile" $estensione`.ts
	 echo "# ORIG da agganciare : $ORIG_DA_AGGANCIARE"
         NOME_FINALE=`basename "$nomefile" $estensione`.mp4
	 echo "# FINALE in elaborazione : $FINAL/$NOME_FINALE"
	 rm -f $FINAL/$NOME_FINALE
	 avconv -i "concat:$INTRO_DA_AGGANCIARE|$ORIG_DA_AGGANCIARE" -c copy  -bsf:a aac_adtstoasc -y  $FINAL/$NOME_FINALE
	 cd $FINAL
	 find -name "*_*" -type f | rename 's/_/ /g'
	 cd -
	 # find -name "* *" -type f | rename 's/ /_/g'
	 # codifica join
     else
         echo "# ERRORE: file INTRO non trovato per questo ORIGINAL"
     fi
    else
        echo "#  Copia in corso per il file. File non pronto per elaborazione. Attendo Termine.  :  $nomefile  "
    fi
   break
   # interrompo, perchè mi limito a elaborare il primo file trovato. vedo se arrivano altri file INTRO
  fi
 done

 
 sleep 2
 echo "# Riciclo ==== AVconv V$version ================================="
done

# =======================================================================
