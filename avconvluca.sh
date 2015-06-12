#!/bin/bash

version="1.0"
# CHANGELOG
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
 # avconv  -i $IN/"$nomefile" -vcodec libx264 -acodec aac  -r $rate -bsf:v h264_mp4toannexb -f mpegts -strict experimental -y $OUT/`basename "$nomefile" $estensione`.ts
 #  -preset superfast  -preset medium    -preset veryslow :  -threads 0 
 # rm -f $OUT/`basename "$nomefile" $estensione`.mp4
 #avconv -i $IN/"$nomefile"  -vcodec libx264  -acodec libmp3lame -qscale 20     $OUT/`basename "$nomefile" $estensione`.mp4
 # avconv -i ORIGINAL-elaborated/ISOARDI_VALENTINA_.3DC145._IAB_3357.MOV  -t 00:00:20 -vcodec libx264 -b:v 500k -maxrate 500k -bufsize 1000k -preset ultrafast -profile:v baseline -strict experimental -acodec aac -b:a 128k -threads 0 FINAL/ISOARDI_VALENTINA_manuale.mp4
 #avconv -i $IN/"$nomefile"  -vcodec libx264 -preset $preset -profile:v $profile -r $rate -f mpegts -b:v $bitrate -bsf:v h264_mp4toannexb    -acodec aac -b:a 128k -strict experimental  -threads 0   $OUT/`basename "$nomefile" $estensione`.ts -y
 avconv -i $IN/"$nomefile" -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $bitrate -acodec aac -b:a 128k -strict experimental  -threads 0   $OUT/`basename "$nomefile" $estensione`.ts -y
}

# =======================================================================
while true
do

 echo "# Controllo INTRO"
 IN="/CONDIVISA/INTRO-incoming"
 OUT="/CONDIVISA/INTRO-completed"
 OLD="/CONDIVISA/INTRO-elaborated"
 OUT_INTRO=OUT
 cd $IN
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
	mv -v -f mefile $OLD/$nomefile
   else
 	echo "#  Copia in corso per il file. File non pronto per elaborazione. Attendo Termine.  :  $nomefile  "
   fi
  fi
 done

############## ORIG ###################################################

 echo "# Controllo ORIGINALI"
 IN="/CONDIVISA/ORIGINAL-incoming"
 OUT="/CONDIVISA/ORIGINAL-completed"
 OLD="/CONDIVISA/ORIGINAL-elaborated"
 FINAL="/CONDIVISA/FINAL"
 cd $IN
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
	OUT_INTRO="/CONDIVISA/INTRO-completed"
	INTRO_DA_AGGANCIARE=`ls $OUT_INTRO/*$KEY_INTRO*`
        echo "# Intro da agganciare : $INTRO_DA_AGGANCIARE"

	# se non trova INTRO da agganciare da errore ed esce
	if [ -f $OUT_INTRO/*$KEY_INTRO* ]
  	then
         echo "# INTRO trovato per questo ORIGINAL"	
	 codifica
         echo "#  Sposto ORIG file in elaborati"
         mv -f -v $nomefile $OLD/$nomefile

	 ORIG_DA_AGGANCIARE=$OUT/`basename "$nomefile" $estensione`.ts
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
