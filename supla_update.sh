#!/bin/bash

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=25
WIDTH=40
CHOICE_HEIGHT=29
BACKTITLE="SUPLA FIRMWARE UPDATE"
TITLE="PLYTKI"
MENU="Wybierz plytke:"

SZEROKOSC=197

OPTIONS=(1 "k_gate_module_v3"
		 2 "k_gate_module"
		 3 "k_dimmer"
		 4 "k_dimmer_din"
		 5 "k_gniazdko_neo"
		 6 "k_rs_module_v3"
		 7 "k_rs_module_v4 AC"
		 8 "k_switch_dual"
		 9 "k_socket_SSR"
		 10 "k_yunschan"
		 11 "k_smoke_module"
		 12 "k_socket_DHT22"
		 13 "k_sonoff_touch_dual"
		 14 "k_sonoff_touch_triple"
		 15 "k_versa_module")

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
			SPI=DIO
			PARAM=6
			break
            ;;
		2)
            BOARD=k_gate_module
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
        3)
            BOARD=k_dimmer
			FLASH_SIZE=4096
			NOSSL=1
			SPI=DIO
			PARAM=6
			break
            ;;
		4)
            BOARD=k_dimmer_din
			FLASH_SIZE=4096
			NOSSL=1
			SPI=DIO
			PARAM=6
			break
            ;;
		5)
            BOARD=k_gniazdko_neo
			FLASH_SIZE=1024
			NOSSL=0
			SPI=DIO
			PARAM=2
			break
            ;;
		6)
            BOARD=k_rs_module_v3
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		7)
            BOARD=k_rs_module_v4
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		8)
            BOARD=k_switch_dual
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		9)
            BOARD=k_socket_SSR
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		10)
            BOARD=k_yunschan
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		11)
            BOARD=k_smoke_module
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		12)
            BOARD=k_socket_DHT22
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
		13)
            BOARD=k_sonoff_touch_dual
			FLASH_SIZE=1024
			NOSSL=0
			SPI=DOUT
			PARAM=2
			break
            ;;
		14)
            BOARD=k_sonoff_touch_triple
			FLASH_SIZE=1024
			NOSSL=0
			SPI=DOUT
			PARAM=2
			break
            ;;
		15)
            BOARD=k_versa_module
			FLASH_SIZE=4096
			NOSSL=0
			SPI=DIO
			PARAM=6
			break
            ;;
  esac
done

if [ $NOSSL == 1 ]
then
	PLIK="$BOARD"_nossl_user1."$FLASH_SIZE"_"$SPI".new."$PARAM".sdk3x.bin;
	PLIK2="$BOARD"_nossl_user2."$FLASH_SIZE"_"$SPI".new."$PARAM".sdk3x.bin;
else
	PLIK="$BOARD"_user1."$FLASH_SIZE"_"$SPI".new."$PARAM".sdk3x.bin;
	PLIK2="$BOARD"_user2."$FLASH_SIZE"_"$SPI".new."$PARAM".sdk3x.bin;
fi

echo "$PLIK";
echo "$PLIK2";

if [ -d /media/QNAP/ESP_Firmware/signed/ ]
then
	echo "QNAP podmontowany";
else
	~/qnap_mont.sh
fi

if [ -e /media/QNAP/ESP_Firmware/signed/$PLIK ] && [ -e /media/QNAP/ESP_Firmware/signed/$PLIK2 ]
then

	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Znalazlem w QNAP signed: \n $PLIK \n $PLIK2 \n Czy skopiowac ?" 10 52
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
	
	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --msgbox "Nie nalazlem w QNAP signed: \n $PLIK \n $PLIK2 \n Zapomniales skompilowac !" 10 52
	exit
	
fi

rm -f /var/www/html/update/$PLIK
rm -f /var/www/html/update/$PLIK2
cp /media/QNAP/ESP_Firmware/signed/$PLIK /var/www/html/update/$PLIK
cp /media/QNAP/ESP_Firmware/signed/$PLIK2 /var/www/html/update/$PLIK2
		
	if [ -e /var/www/html/update/$PLIK ] && [ -e /var/www/html/update/$PLIK2 ]
	then	

	dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Udane skopiowanie do www/update: \n $PLIK \n $PLIK2 \n Czy zaktualizowac wpisy w esp_update ?" 10 52
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "wpis esp_update dla $BOARD";
			case $BOARD in
				k_gate_module_v3)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=27 or id=28 or id=29 or id=30 or id=31 or id=32" > update.txt;
					;;
				k_gate_module)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=37 or id=38" > update.txt;
					;;
				k_dimmer)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=33 or id=34" > update.txt;
					;;
				k_dimmer_din)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=59 or id=60 or id=61 or id=62 or id=63 or id=64" > update.txt;
					;;
				k_gniazdko_neo)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=1 or id=2" > update.txt;
					;;
				k_rs_module_v3)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=5 or id=6 or id=7 or id=8 or id=9 or id=10" > update.txt;
					;;
				k_rs_module_v4)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=41 or id=42 or id=43 or id=44 or id=45 or id=46" > update.txt;
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
				k_versa_module)
					cd /home/pi
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=39 or id=40" > update.txt;
					;;
			esac
			dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Wpis w esp_update przed modyfikacja :" --textbox "update.txt" 20 $SZEROKOSC
		    while :
		    do
				LINIE=$( wc -l < update.txt );
				((LINIE--));
				echo "Liczba lini w update.txt : $LINIE";
				WYNIK=0;
				while read line; do
					if echo "$line" | grep -q "$PLIK"; then ((WYNIK++)); fi
					if echo "$line" | grep -q "$PLIK2"; then ((WYNIK++)); fi
				done < update.txt
				echo "WYNIK=$WYNIK, LINIE=$LINIE";
			if [ $WYNIK == $LINIE ]
			then
				echo " Wpisy sie zgadzaja "
			else 
				echo " Wpisy sie nie zgadzaja!!! "
			fi
			#exit;
				if [ $WYNIK == $LINIE ];
				then
					while [ -z "$NEWVER" ]; do
						VER=$(cut -f 5 update.txt | tail -1);
						echo "$VER";
						NEWVER=$( dialog --backtitle "SUPLA FIRMWARE UPDATE" --inputbox "Dla $BOARD wersja softu : $VER \n  Wprowadz nowa wersje:" 12 40 3>&1 1>&2 2>&3 3>&- )
						if [ -z "$NEWVER" ];
						then 
							dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Nic nie wpisales ! \n Czy chcesz wyjsc ?" 10 40
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
						k_gate_module)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=37 or id=38";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=37 or id=38" > update.txt;
							;;
						k_dimmer)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=33 or id=34";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=33 or id=34" > update.txt
							;;
						k_dimmer_din)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=59 or id=60 or id=61 or id=62 or id=63 or id=64";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=59 or id=60 or id=61 or id=62 or id=63 or id=64" > update.txt
							;;
						k_gniazdko_neo)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=1 or id=2";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=1 or id=2" > update.txt
							;;
						k_rs_module_v3)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=5 or id=6 or id=7 or id=8 or id=9 or id=10";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=5 or id=6 or id=7 or id=8 or id=9 or id=10" > update.txt
							;;
						k_rs_module_v4)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=41 or id=42 or id=43 or id=44 or id=45 or id=46";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=41 or id=42 or id=43 or id=44 or id=45 or id=46" > update.txt
							;;
						k_switch_dual)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=19 or id=20 or id=21 or id=22 or id=23 or id=24";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=19 or id=20 or id=21 or id=22 or id=23 or id=24" > update.txt
							;;
						k_socket_SSR)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=25 or id=26";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=25 or id=26" > update.txt
							;;
						k_yunschan)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=3 or id=4";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=3 or id=4" > update.txt
							;;
						k_smoke_module)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=17 or id=18";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=17 or id=18" > update.txt
							;;
						k_socket_DHT22)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=15 or id=16";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=15 or id=16" > update.txt
							;;
						k_sonoff_touch_dual)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=11 or id=12";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=11 or id=12" > update.txt
							;;
						k_sonoff_touch_triple)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=13 or id=14";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=13 or id=14" > update.txt
							;;
						k_versa_module)
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set latest_software_version='$NEWVER' WHERE id=39 or id=40";
							rm -f ~/update.txt
							source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=39 or id=40" > update.txt
							;;
					esac
					dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
					rm -f ~/update.txt
					source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id<100 " > update.txt
					dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Wszystkie wpisy w esp_update :" --textbox "update.txt" 45 $SZEROKOSC
					rm -f ~/update.txt
					exit;
				else
					dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --yesno "Nie zgadza sie wpis esp_update z $PLIK ! \n Czy chcesz naprawic ? " 10 52
					YOUR_CHOOSE=$?;
					if [ "$YOUR_CHOOSE" == 0 ];
					then
						case $BOARD in
							k_gate_module_v3)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=28 or id=30 or id=32";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=27 or id=29 or id=31";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=27 or id=28 or id=29 or id=30 or id=31 or id=32" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_gate_module)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=38";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=37";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=37 or id=38" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_dimmer)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=34";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=33";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=33 or id=34" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_dimmer_din)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=59 or id=61 or id=63";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=60 or id=62 or id=64";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=59 or id=60 or id=61 or id=62 or id=63 or id=64" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_gniazdko_neo)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=2";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=1";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=1 or id=2" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_rs_module_v3)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=6 or id=8 or id=10";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=5 or id=7 or id=9";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=5 or id=6 or id=7 or id=8 or id=9 or id=10" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_rs_module_v4)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=42 or id=44 or id=46";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=41 or id=43 or id=45";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=41 or id=42 or id=43 or id=44 or id=45 or id=46" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_switch_dual)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=20 or id=22 or id=24";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=19 or id=21 or id=23";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=19 or id=20 or id=21 or id=22 or id=23 or id=24" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_socket_SSR)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=26";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=25";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=25 or id=26" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_yunschan)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=4";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=3";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=3 or id=4" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_smoke_module)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=18";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=17";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=17 or id=18" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_socket_DHT22)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=16";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=15";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=15 or id=16" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_sonoff_touch_dual)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=12";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=11";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=11 or id=12" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_sonoff_touch_triple)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=14";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=13";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=13 or id=14" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;
							k_versa_module)
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK' WHERE id=40";
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "UPDATE esp_update set path='get_file.php?file=$PLIK2' WHERE id=39";
								rm -f ~/update.txt
								source supla-docker/.env && docker exec supla-db mysql -u supla --password=$DB_PASSWORD supla -e "SELECT * FROM esp_update WHERE id=39 or id=40" > update.txt;
								dialog --backtitle "SUPLA FIRMWARE UPDATE" --title "Zaktualizowany wpis path w esp_update :" --textbox "update.txt" 20 $SZEROKOSC
								;;	
						esac
					else [ "$YOUR_CHOOSE" == 1 ];
						echo "Wybrałeś Nie";
						rm -f ~/update.txt
						exit;
					fi
				fi
			done
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
		dialog --clear --backtitle "SUPLA FIRMWARE UPDATE" --msgbox "Nie udalo sie skopiowac do www/update: \n $PLIK \n $PLIK2 ! \n Sprawdz log." 10 52
		rm -f ~/update.txt
		exit
	fi