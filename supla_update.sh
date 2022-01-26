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

rm -f ~/update.txt

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

echo "$PLIK";
echo "$PLIK2";

if [ -e /media/QNAP/ESP_Firmware/signed/$PLIK ] && [ -e /media/QNAP/ESP_Firmware/signed/$PLIK2 ]
then

	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Znalazlem w QNAP signed: \n  $PLIK  $PLIK2 \n Czy skopiowac ?" 10 52
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "Kopiowanie plikow";
		elif [ "$YOUR_CHOOSE" == 1 ];
		then
			echo "Wybrałeś Nie";
			rm -f ~/update.txt
			exit;
		else
			echo "Niczego nie wybrałeś";
			rm -f ~/update.txt
			exit;
		fi
		
else
	
	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --msgbox "Nie nalazlem w QNAP signed: \n  $PLIK  $PLIK2 \n Zapomniales skompilowac !" 10 52
	exit
	
fi

rm -f /var/www/html/update/$PLIK
rm -f /var/www/html/update/$PLIK2
cp /media/QNAP/ESP_Firmware/signed/$PLIK /var/www/html/update/$PLIK
cp /media/QNAP/ESP_Firmware/signed/$PLIK2 /var/www/html/update/$PLIK2
		
	if [ -e /var/www/html/update/$PLIK ] && [ -e /var/www/html/update/$PLIK2 ]
	then	

	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Udane skopiowanie do www/update: \n  $PLIK  $PLIK2 \n Czy zaktualizowac wpisy w esp_update ?" 10 52
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "wpis esp_update dla $BOARD";
			case $BOARD in
				k_gate_module_v3)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=27 or id=28 or id=29 or id=30 or id=31 or id=32" > update.txt;
					;;
				k_dimmer)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=33 or id=34" > update.txt;
					;;
				k_gniazdko_neo)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=1 or id=2" > update.txt;
					;;
				k_rs_module_v3)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=5 or id=6 or id=7 or id=8 or id=9 or id=10" > update.txt;
					;;
				k_switch_dual)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=19 or id=20 or id=21 or id=22 or id=23 or id=24" > update.txt;
					;;
				k_socket_SSR)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=25 or id=26" > update.txt;
					;;
				k_yunschan)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=3 or id=4" > update.txt;
					;;
				k_smoke_module)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=17 or id=18" > update.txt;
					;;
				k_socket_DHT22)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=15 or id=16" > update.txt;
					;;
				k_sonoff_touch_dual)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=11 or id=12" > update.txt;
					;;
				k_sonoff_touch_triple)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=13 or id=14" > update.txt;
					;;
			esac
			dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Wpis w esp_update przed modyfikacja :" --textbox "update.txt" 20 185
			while read line; do
				if  echo "$line" | grep -q "$PLIK"; then echo "Jest ok w pliku wynik.txt"; fi
			done < update.txt
			while [ -z "$NEWVER" ]; do
				VER=$(cut -f 5 update.txt | tail -1);
				echo "$VER";
				NEWVER=$( dialog --backtitle "SUPLA FIRMWARE UPDATE" --inputbox "Dla $BOARD wersja softu : $VER \n  Wprowadz nowa wersje:" 12 40 3>&1 1>&2 2>&3 3>&- )
				if [ -z "$NEWVER" ];
					then 
					dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Nic nie wpisales ! \n  Czy chcesz wyjsc ?" 10 40
					YOUR_CHOOSE=$?;
					if [ "$YOUR_CHOOSE" == 0 ];
						then
						rm -f ~/update.txt
						exit;
					fi
				fi
			done
			echo "Nowa wersja : $NEWVER";
			case $BOARD in
				k_gate_module_v3)
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=27 or id=28 or id=29 or id=30 or id=31 or id=32";
					rm -f ~/update.txt
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=27 or id=28 or id=29 or id=30 or id=31 or id=32" > update.txt;
					;;
				k_dimmer)
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=33 or id=34";
					rm -f ~/update.txt
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=33 or id=34" > update.txt
					;;
			esac
			dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis w esp_update :" --textbox "update.txt" 20 185
		elif [ "$YOUR_CHOOSE" == 1 ];
		then
			echo "Wybrałeś Nie";
			rm -f ~/update.txt
			exit;
		else
			echo "Niczego nie wybrałeś";
			rm -f ~/update.txt
			exit;
		fi
	else
		dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --msgbox "Nie udalo sie skopiowac do www/update: \n  $PLIK  $PLIK2 ! \n Sprawdz log." 10 52
		rm -f ~/update.txt
		exit
	fi