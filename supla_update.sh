#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=20
WIDTH=40
CHOICE_HEIGHT=29
BACKTITLE="SUPLA FIRMWARE UPDATE"
TITLE="PLYTKI"
MENU="Wybierz plytke:"

OPTIONS=(1 "k_gate_module_v3"
		 2 "k_dimmer"
		 3 "k_gniazdko_neo"
		 4 "k_rs_module_v3"
		 5 "k_switch_dual"
		 6 "k_socket_SSR"
		 7 "k_yunschan"
		 8 "k_smoke_module"
		 9 "k_socket_DHT22"
		 10 "k_sonoff_touch_dual"
		 11 "k_sonoff_touch_triple")

# rm -f /CProjects/supla-espressif-esp/firmware/result.txt
# rm -f /CProjects/supla-espressif-esp/firmware/result2.txt
rm -f ~/update.txt
rm -f ~/wynik.txt
rm -f ~/fraza.txt

while true; do
	exec 3>&1

		CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 1>&3)
  exit_status=$?
  exec 3>&-
  case $exit_status in
    $DIALOG_CANCEL)
      clear
      echo "Nie wybrales zadnej plytki !."
      exit
      ;;
    $DIALOG_ESC)
      clear
      echo "Program aborted." >&2
      exit 1
      ;;
  esac
  case $CHOICE in
        1)
            BOARD=k_gate_module_v3
			FLASH_SIZE=4096
			NOSSL=0
			break
            ;;
        2)
            BOARD=k_dimmer
			FLASH_SIZE=4096
			NOSSL=1
			break
            ;;
		3)
            BOARD=k_gniazdko_neo
			FLASH_SIZE=1024
			break
            ;;
		4)
            BOARD=k_rs_module_v3
			FLASH_SIZE=4096
			break
            ;;
		5)
            BOARD=k_switch_dual
			FLASH_SIZE=4096
			break
            ;;
		6)
            BOARD=k_socket_SSR
			FLASH_SIZE=4096
			break
            ;;
		7)
            BOARD=k_yunschan
			FLASH_SIZE=4096
			break
            ;;
		8)
            BOARD=k_smoke_module
			FLASH_SIZE=4096
			break
            ;;
		9)
            BOARD=k_socket_DHT22
			FLASH_SIZE=4096
			break
            ;;
		10)
            BOARD=k_sonoff_touch_dual
			FLASH_SIZE=1024
			break
            ;;
		11)
            BOARD=k_sonoff_touch_triple
			FLASH_SIZE=1024
			break
            ;;
  esac
done

if [ $NOSSL == 1 ]
then
	PLIK="$BOARD"_nossl_user1."$FLASH_SIZE"_DIO.new.6.sdk3x.bin;
	PLIK2="$BOARD"_nossl_user2."$FLASH_SIZE"_DIO.new.6.sdk3x.bin;
else
	PLIK="$BOARD"_user1."$FLASH_SIZE"_DIO.new.6.sdk3x.bin;
	PLIK2="$BOARD"_user2."$FLASH_SIZE"_DIO.new.6.sdk3x.bin;
fi

# rm -f /CProjects/supla-espressif-esp/firmware/$PLIK
# rm -f /CProjects/supla-espressif-esp/firmware/$PLIK2
echo "$PLIK";
echo "$PLIK2";


if [ -e /media/QNAP/ESP_Firmware/signed/$PLIK ] && [ -e /media/QNAP/ESP_Firmware/signed/$PLIK2 ]
then

	dialog --clear --yesno "Znalazlem w QNAP signed:   $PLIK  $PLIK2	Czy skopiowac ?" 10 52
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "Kopiowanie plikow";
		elif [ "$YOUR_CHOOSE" == 1 ];
		then
			echo "Wybrałeś Nie";
			exit;
		else
			echo "Niczego nie wybrałeś";
			exit;
		fi
		
else
	
	dialog --clear --msgbox "Nie nalazlem w QNAP signed:   $PLIK  $PLIK2	Zapomniales skompilowac !" 10 52
	exit
	
fi

rm -f /var/www/html/update/$PLIK
rm -f /var/www/html/update/$PLIK2
cp /media/QNAP/ESP_Firmware/signed/$PLIK /var/www/html/update/$PLIK
cp /media/QNAP/ESP_Firmware/signed/$PLIK2 /var/www/html/update/$PLIK2
		
	if [ -e /var/www/html/update/$PLIK ] && [ -e /var/www/html/update/$PLIK2 ]
	then	

	dialog --clear --yesno "Udane skopiowanie do www/update:   $PLIK  $PLIK2	Czy zaktualizowac wpisy w esp_update ?" 10 52
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "wpis esp_update dla $BOARD";
			PATH=get_file.php?file=$PLIK;
			cd /home/pi
			source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE path=$PATH" > update.txt;
			#echo "$PLIK2" > fraza.txt;
			#grep -n "^${PLIK2}" > wynik.txt;
		elif [ "$YOUR_CHOOSE" == 1 ];
		then
			echo "Wybrałeś Nie";
			exit;
		else
			echo "Niczego nie wybrałeś";
			exit;
		fi
	else
		dialog --clear --msgbox "Nie udalo sie skopiowac do www/update:   $PLIK  $PLIK2 ! Sprawdz log." 10 52
		exit
	fi