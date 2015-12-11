#!/bin/bash

#version="1.3"
# CHANGELOG
# ---------------------------
# 2015-12-09 v1.4
# corretto moltissimi bug della nuova versione
# ---------------------------
# 2015-12-07 v1.3
# abilitati i log
# ---------------------------
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

function lettura_parametri
{
 file="/scripts/parametri.txt"
 while read line
 do
	vbitrate=$line
	read line
	abitrate=$line
	read line
	rate=$line
	read line
	preset=$line
#	read line
#	ver=$line
        ver="1.4"
 done <"$file" 
 
}

function codifica
{
 # options: ultrafast, superfast, veryfast, faster, fast, medium (default), slow and veryslow
 #preset=medium
 profile=baseline
 #vbitrate=5000k
 #abitrate=128000
 #rate=30
 #echo avconv -i $IN/$nomefile -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $vbitrate -acodec aac -b:a $abitrate -strict experimental  -threads 0   $OUT/basename $nomefile $estensione.ts -y

 avconv -i $IN/"$nomefile" -loglevel error -vcodec libx264 -preset $preset -profile:v $profile  -level 30  -r $rate -f mpegts -b:v $vbitrate -acodec aac -b:a $abitrate -strict experimental  -threads 0   $OUT/`basename "$nomefile" $estensione`.ts -y
}

# =======================================================================
while true
do
 lettura_parametri
 #echo "# Controllo INTRO"
 intro_IN="/CONDIVISA/intro-IN"
 intro_OUT="/CONDIVISA/intro-OUT"
 intro_OLD="/CONDIVISA/intro-OLD"
 #OUT_INTRO=OUT
 cd $intro_IN
 #echo $intro_IN
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
 	echo "# INTRO: pronto per elaborazione            : $nomefile"
        echo "# INTRO: in elaborazione                    : $nomefile"
	estensione=".avi"
	IN=$intro_IN
	OUT=$intro_OUT
 	codifica
 	echo "# INTRO: in spostamento da IN a OLD         : $nomefile "
	mv -f $nomefile $intro_OLD/$nomefile
   else
 	echo "# INTRO: nuovo presente. Attendo sia libero :  $nomefile  "
   fi
  fi
 done

############## ORIG ###################################################

 #echo "# Controllo video ORIGINALI"
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
	# rimuovo spazi dal file ORIG
 	find -name "* *" -type f | rename 's/ /_/g'
        echo "# VIDEO: input pronto                : $nomefile"
        echo "# VIDEO: input in elaborazione       : $nomefile"
	estensione=".MOV"
	KEY_INTRO=`echo $nomefile | cut -f 2 -d "."`
	echo "# VIDEO: recupero INTRO con CODICE   : $KEY_INTRO"
	# mettere controllo. se keyintro ="" allora esci segnalando errore
	#OUT_INTRO="/CONDIVISA/INTRO-completed"
	INTRO_DA_AGGANCIARE=`ls $intro_OUT/*$KEY_INTRO*`
        echo "# VIDEO: intro teorico da agganciare : $INTRO_DA_AGGANCIARE"

	# se non trova INTRO da agganciare da errore ed esce
	if [ -f $intro_OUT/*$KEY_INTRO* ]
  	then
         echo "# VIDEO: intro trovato"	
	 IN=$video_IN
	 OUT=$video_OUT
	 codifica
         echo "# VIDEO: sposto da IN a OLD"
         mv -f $nomefile $video_OLD/$nomefile

	 ORIG_DA_AGGANCIARE=$video_OUT/`basename "$nomefile" $estensione`.ts
	 echo "# FINALE: intro out da concatenare : $INTRO_DA_AGGANCIARE"
	 echo "# FINALE: video out da concatenare : $ORIG_DA_AGGANCIARE"
         NOME_FINALE=`basename "$nomefile" $estensione`.mp4
	 echo "# FINALE: in elaborazione         : $FINAL/$NOME_FINALE"
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
        echo "# VIDEO: Copia in corso per il file. File non pronto per elaborazione. Attendo Termine.  :  $nomefile  "
    fi
   break
   # interrompo, perchè mi limito a elaborare il primo file trovato. vedo se arrivano altri file INTRO
  fi
 done

 
 sleep 5
 echo "# Ciclo ==== AVconv V$ver ========"
done

# =======================================================================
