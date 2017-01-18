#!/bin/bash
#################################################################################
# Backup_Linux_Settings V.16: Makes a tar.7zip file of you Linux Mint settings	#
#                                                                         		#
# Copyright (C) 2014 Bastian Noller                                       		#
# email: bastian.noller[-A.T.-]web.de                                     		#
#                                         								  		#
#                                                                         		#
#    This program is free software: you can redistribute it and/or modify		#
#    it under the terms of the GNU General Public License as published by		#
#    the Free Software Foundation, either version 3 of the License, or			#
#    (at your option) any later version.										#
#																				#
#    This program is distributed in the hope that it will be useful,			#
#    but WITHOUT ANY WARRANTY; without even the implied warranty of				#
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the				#
#    GNU General Public License for more details.								#
#																				#
#    You should have received a copy of the GNU General Public License			#
#    along with this program.  If not, see <http://www.gnu.org/licenses/> 		#
#                                                                         		#
#################################################################################


# Use this script to backup your current Linux settings (You can later on restore them with the >>Restore_Linux_Settings<< script).
#This script is intended for Linux Mint. Most likely it will also work for Ubuntu. Please tell the script were to store your backups
#(backup *.tar.7zip files will be stored there), by editing the destination variable below:
##############################################################################################################################################
##############################################################################################################################################

destination="/media/tiago/SSD180/katana_backup/" 	# determines the destination folder were the backup will be stored. This is the only variable you should edit if you are not a advanced user.
											# Please don't make the mistake to backup into the same partition you will install the new Linux version later on.
##############################################################################################################################################
##############################################################################################################################################
##text types and colors
# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BWhite='\e[1;37m'       # White


## make sure you are sudo:
if [[ $EUID -ne 0 ]]; then
	echo "Please run this script with sudo privileges (enter password below:)"
	exec sudo bash "$0" "$@" #run script as sudo or su
else
	echo ""
fi

##check if all packages are available to run this script:
echo "Checking if necessary packages are available on your PC to run this script:"
echo ""

dpkg -l apt > /dev/null 2>&1
INSTALLED=$?
if [ $INSTALLED == '0' ]; then
		echo -e "+ apt is installed on your system (can use apt to restore packages) --> ${Green}OK${Color_Off}"
else
		echo ""
 		echo -e "The script has detected that ${Red}>>apt<< is NOT installed${Color_Off} on your system."
  		echo "However, apt is needed for this script to work."
		echo "Apt can not be automatically installed using this script. Please use your package manager (e.g., Synaptic) to install apt."
  		read -p "Press any key to exit, goodbye." -n1 -s
		exit
fi


dpkg -l p7zip > /dev/null 2>&1
INSTALLED=$?
if [ $INSTALLED == '0' ]; then
		echo -e "+ 7zip compression is installed on your system (7za command available) --> ${Green}OK${Color_Off}"
else
		echo ""
 		echo -e "The script has detected that ${Red}>>7za<< is NOT installed${Color_Off} on your system."
  		echo "However, 7za compression is needed for this script to work."
		echo ""
		echo "Press any key to install the required package (recommended) or close the terminal to aboard."
  		read -p "If the automatic installation fails, please install >>p7zip<< package by hand using your package manager." -n1 -s
  		apt-get install p7zip
fi

dpkg -l tar > /dev/null 2>&1
INSTALLED=$?
if [ $INSTALLED == '0' ]; then
		echo -e "+ tar container format is installed on your system (tar command available) --> ${Green}OK${Color_Off}"
else
		echo ""
 		echo -e "The script has detected that ${Red}>>tar<< is NOT installed${Color_Off} on your system."
  		echo "However, the tar container format is needed for this script to work."
		echo ""
		echo "Press any key to install the required package (recommended) or close the terminal to aboard."
  		read -p "If the automatic installation fails, please install >>tar<< package by hand using your package manager." -n1 -s
  		apt-get install tar
fi

dpkg -l grep > /dev/null 2>&1
INSTALLED=$?
if [ $INSTALLED == '0' ]; then
		echo -e "+ grep is installed on your system (grep command available) --> ${Green}OK${Color_Off}"
else
		echo ""
 		echo -e "The script has detected that ${Red}>>grep<< is NOT installed${Color_Off} on your system."
  		echo "However, grep is needed for this script to work."
		echo ""
		echo "Press any key to install the required package (recommended) or close the terminal to aboard."
  		read -p "If the automatic installation fails, please install >>grep<< package by hand using your package manager." -n1 -s
  		apt-get install grep
fi

echo ""
sleep 2

## fetch the Linux version you are about to back up and start backup:
version=$(lsb_release -d | sed -n 's/Description:[\t]//p' | tr " " _)
Date=""_"`date +"%Y%m%d"`"
ArchiveFormat=".tar"
CompressionFormat1=".7zip"
compression_rate="0" # smaller values --> larger file size but faster
echo "#########################################################"
echo -e "${BWhite}This is Version 16 of the Backup Script${Color_Off}"
echo "#########################################################"
echo -e "${BGreen}NEW:${Color_Off} uses *.tar.7zip backup archive."
echo "This is only compatible with restore script version 10 or higher."
echo "#########################################################"
echo "#########################################################"
echo "Detected Linux Version:"
echo $version
echo "#########################################################"
read -p "Press any key to start backup process or close shell to aboard." -n1 -s
echo ""
echo "Backing up home folder of current Linux distribution, while preserving all owners and rights."
sleep 3
mkdir -p $destination
tar --exclude='/home/tiago/vmware' --exclude='/home/tiago/Downloads' --exclude='/home/tiago/tmp' -upvf "$destination$version$Date$ArchiveFormat" /home/ # c=create a new archive, f=use archive file or device ARCHIVE, u=only append files newer than copy in archive, p=extract information about file permissions, v=verbosely list files processed, z=filter the archive through gzip
echo "Backed up your home folder of Linux. This can become important when installing a new release of Linux Mint (restore personal settings)"
sleep 1
echo "Now backing up your etc-settings (all of them)"
sleep 1
tar -upvf "$destination$version$Date$ArchiveFormat" /etc/
echo "Backed up your etc folder of Linux, while preserving all owners and rights. This can become important when installing a new release of Linux Mint (restore some further program settings)"
sleep 1
echo "Making a list of all of the programs you have installed with package manager"
sleep 1
mkdir -p /Installed_Programs # creating the temporary folder for storing software lists.
dpkg --list | grep -v -e '-dev' -e 'ii  lib' >/Installed_Programs/packages.list
dpkg --get-selections > /Installed_Programs/Package.txt
echo "Making a list of all of the programs you have installed from source or binaries"
sleep 1
ls -1 /opt >/Installed_Programs/binary_packages.txt
ls -1 /usr/local/bin >/Installed_Programs/source_packages.txt
cp -R /etc/apt/sources.list* /Installed_Programs/
echo "Getting your Repro Key (public key)"
sleep 1
apt-key exportall > /Installed_Programs/Repo.keys
echo "Adding new files to tar, while preserving all owners and rights."
sleep 1
tar -upvf "$destination$version$Date$ArchiveFormat" /Installed_Programs/
echo ""
echo "Compressing the generated *.tar file to 7zip (this can take a while):"
sleep 1
echo ""
echo -e "${BGreen}Since the backup can contain confidential information, we will now encrypt the backup.${Color_Off}"
echo "Please chose a password you can remember or leave the password blank if you don't want password protection."
echo ""
sleep 1
7za u -p -mx=$compression_rate "$destination$version$Date$ArchiveFormat$CompressionFormat1" "$destination$version$Date$ArchiveFormat"
echo "Compression is finished."
echo "Deleting the temporary folder for storing software lists."
sleep 1
rm -R /Installed_Programs # deleting the temporary folder for storing software lists.
echo "Deleting the temporary tape archive for storing all files, while preserving all owners and rights."
sleep 1
rm "$destination$version$Date$ArchiveFormat"
echo "Backup script has finished."
echo -e "If there were no errors, you can now find a file named ${BGreen}>>$version$Date$ArchiveFormat$CompressionFormat1<<${Color_Off} in the folder ${BGreen}$destination${Color_Off} that includes all your backed up information."
echo "Have a nice day."
read -p "Press any key to exit the backup script. " -n1 -s
echo ""
################################################################################################################
################################################################################################################
#echo "backing up the >>Daten drive<< to the >>Backup drive<<"
#rsync -auv --log-file=/home/user/$(date +%Y%m%d)_rsync.log --progress /media/Daten/ /media/Backup
#echo "Backup script has finished. Have a nice day."
#read -p "Press any key to continue... " -n1 -s
