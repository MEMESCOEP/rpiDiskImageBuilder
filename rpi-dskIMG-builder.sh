RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
echo [===== Raspberry Pi Disk Image Builder =====]
echo

dev(){
	read -p "Device to back up (/dev/DEVICE-ID): " device
	read -p "OS Name: " osname
	read -p "OS Version: " osver
	read -p "Is the following information correct? (Device: $device || OS Name: $osname || OS Version: $osver) [Y/n]: " correctinfo
	if [ "$correctinfo" != "${correctinfo#[Yy]}" ] ;then
    start
else
    dev
fi

}



start(){
printf "${BLUE}[INFO] >> Preparing to copy from device: $device to Image: $PWD/$osname($osver).img...\n"

if ! command -v sudo dd bs=4M if=$device of="$osname($osver).img" &> /dev/null 
then
    printf "${RED}[ERROR] >> The specified device could not be found.\n"
    exit 1
    
else
	printf "${BLUE}[INFO] >> Starting image build (THIS MAY TAKE A WHILE)...\n"
	printf "${NC}\n"
	sudo dd bs=4M if=$device of="$osname($osver).img" status=progress
	if [ "$?" -ne 0 ]; then
		printf "${RED}[ERROR] >> The specified device ($device) could not be found.\n"
    		exit 1
	else
		printf "${GREEN}[INFO] >> Finished copying from device: $device to Image: $PWD/$osname($osver).img\n"
	fi
fi



echo
printf "${BLUE}[INFO] >> Attempting to start Pishrink...\n"
echo

if ! command -v pishrink.sh &> /dev/null
then
    printf "${RED}[ERROR] >> Failed to start Pishrink because it could not be found.\n"
    exit 1
    
else
	printf "${BLUE}[INFO] >> Located pishrink\n"
	printf "${NC}\n"
	sudo pishrink.sh -a "$osname($osver).img"
	if [ "$?" -ne 0 ]; then
		printf "${RED}[ERROR] >> An error occured!\n"
    		exit 1
	else
		printf "${GREEN}[INFO] >> Finished shrinking image: $PWD/$osname($osver).img\n"
	fi
	
fi
printf "${BLUE}[INFO] >> Compressing OS Image into zip...\n"
printf "${NC}\n"
zip "$osname($osver).zip" "$osname($osver).img"
if [ "$?" -ne 0 ]; then
		printf "${RED}[ERROR] >> An error occured.\n"
    		exit 1
	else
		printf "${GREEN}[INFO] >> Finished compressing image: $PWD/$osname($osver).img into zip file: $osname($osver).zip\n"
	fi
printf "${GREEN}[INFO] >> Final OS Size Before Zip: $fsize\n"
printf "${GREEN}[INFO] >> Final OS Size After Zip: $fsize2\n"
printf "${GREEN}[INFO] >> Finished creating OS: $osname($osver).img!\n"
fsize=$(du -h "$osname($osver).img" | awk '{print $1}')
if [ "$?" -ne 0 ]; then
		printf "${RED}[ERROR] >> An error occured.\n"
    		exit 1
    	fi
fsize2=$(du -h "$osname($osver).zip" | awk '{print $1}')
if [ "$?" -ne 0 ]; then
		printf "${RED}[ERROR] >> An error occured.\n"
    		exit 1
    	fi

printf "${NC}\n"
echo Done.
exit


}
if [ "$EUID" -ne 0 ]
  then 
  	printf "${RED}[ERROR] >> This tool requires root!\n"
  	exit
  else
  	dev
fi
