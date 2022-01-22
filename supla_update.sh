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


if [ -e /media/QNAP/ESP_Firmware/signed/$PLIK && -e /media/QNAP/ESP_Firmware/signed/$PLIK2 ]
then

	dialog --clear --backtitle "Znalazlem $PLIK w QNAP signed Znalazlem $PLIK2 w QNAP signed" --yesno "Czy skopiowac  ?" 10 30
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
		
	if [ -e /CProjects/supla-espressif-esp/firmware/$PLIK2 ]
	then	

	dialog --clear --backtitle "Podpisanie firmware dla $BOARD" --yesno "Czy podpisac firmware dla plytki $BOARD ?" 10 40
		YOUR_CHOOSE=$?;
		if [ "$YOUR_CHOOSE" == 0 ];
		then
			echo "Podpisanie firmware dla $BOARD";
			echo "Firmware : $PLIK";
			echo "Firmware2 : $PLIK2";
			cd  /CProjects/supla-espressif-esp/firmware
			supla-esp-sigtool -k klucz -s $PLIK
			supla-esp-sigtool -k klucz -s $PLIK2
			supla-esp-sigtool -k klucz -v $PLIK &> result.txt
			supla-esp-sigtool -k klucz -v $PLIK2 &> result2.txt
			if  grep -q 'verified' result.txt
			then
				echo "Firmware $PLIK podpisane prawidlowo";
				mkdir -p /CProjects/supla-espressif-esp/firmware/signed
				rm -f /CProjects/supla-espressif-esp/firmware/signed/$PLIK
				cp /CProjects/supla-espressif-esp/firmware/$PLIK /CProjects/supla-espressif-esp/firmware/signed/$PLIK
				rm -f /CProjects/supla-espressif-esp/firmware/$PLIK
				rm -f /CProjects/supla-espressif-esp/firmware/result.txt
				sleep 1
				dialog --clear --msgbox "Firmware $PLIK podpisane i przeniesione do firmware/signed." 10 40
			else
				echo "Nie udalo sie podpisac firmware $PLIK !";
			fi
			if  grep -q 'verified' result2.txt
			then
				echo "Firmware $PLIK2 podpisane prawidlowo";
				mkdir -p /CProjects/supla-espressif-esp/firmware/signed
				rm -f /CProjects/supla-espressif-esp/firmware/signed/$PLIK2
				cp /CProjects/supla-espressif-esp/firmware/$PLIK2 /CProjects/supla-espressif-esp/firmware/signed/$PLIK2
				rm -f /CProjects/supla-espressif-esp/firmware/$PLIK2
				rm -f /CProjects/supla-espressif-esp/firmware/result2.txt
				sleep 1
				dialog --clear --msgbox "Firmware $PLIK2 podpisane i przeniesione do firmware/signed." 10 40
			else
				echo "Nie udalo sie podpisac firmware $PLIK2 !";
			fi
		elif [ "$YOUR_CHOOSE" == 1 ];
		then
			echo "Wybrałeś Nie";
			exit;
		else
			echo "Niczego nie wybrałeś";
			exit;
		fi
	else
		dialog --clear --msgbox "Nie udalo sie skompilowac $BOARD user2 ! Sprawdz log." 10 40
		exit
	fi
		
else
	dialog --clear --msgbox "Nie udalo sie skompilowac $BOARD user1 ! Sprawdz log." 10 40
fi