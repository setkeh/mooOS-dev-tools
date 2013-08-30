#!/bin/sh
## mooOS Installer =)
## 08-27-2013 pdq
## from mooOS livecd/liveusb


### Code be `ere yarrr! ###

## figure out architecture type
archtype="$(uname -m)"

if [ "$archtype" = "x86_64" ]; then
    dialog --backtitle "mooOS Installer" --title "Information" --msgbox "Your architecture type is x86_64, this installer assumes you are using the x86_64 livecd option...\nproceeding (press ESC to exit)" 20 70
    archtype="x86_64"
    not_archtype="i686"
else
    dialog --backtitle "mooOS Installer" --title "Information" --msgbox "Your architecture type is i686, this installer assumes you are using the i686 livecd option... proceeding\n(press ESC to exit)" 20 70
    archtype="i686"
    not_archtype="x86_64"
fi

if [ $? = 255 ] ; then
    exit 0
fi

dialog --clear --backtitle "$upper_title" --title "Architecture type" --yes-label "$archtype" --no-label "$not_archtype" --yesno "Double check. [Select Arch type]" 20 70
if [ $? = 0 ] ; then
        archtype=$archtype
    else
        archtype=$not_archtype
fi

upper_title="mooOS Installer $archtype"
setterm -blank 0

## root script
if [ $(id -u) -ne 0 ]; then
    echo "run this as root"
fi
## styling
clr=""

## temporary files
_TEMP=/tmp/answer$$
mkdir -p /tmp/tmp 2>/dev/null
TMP=/tmp/tmp 2>/dev/null

## functions
exiting_installer() {
    clear
    rm -f $_TEMP
    dialog --clear --backtitle "$upper_title" --title "Exiting Script" --msgbox "type: install_mooOS to re-run" 10 40
    exit 0
}

installer_menu() {
    dialog \
        --colors --backtitle "$upper_title" --title "$upper_title" \
        --menu "Select action: (Do them in order)" 20 60 9 \
        1 $clr"List linux partitions" \
        2 $clr"Partition editor (cfdisk)" \
        3 $clr"Format and/or mount filesystems" \
        4 $clr"Create internet connection" \
        5 $clr"Initial install" \
        6 $clr"Generate fstab" \
        7 $clr"Configure system" \
        8 $clr"Finish and reboot. (Remove livecd after poweroff)" \
        9 $clr"Exit" 2>$_TEMP

    if [ $? = 1 ] || [ $? = 255 ] ; then
        exiting
        return 0
    fi

    choice=$(cat $_TEMP)
    case $choice in
        1) list_partitions;;
        2) partition_editor;;
        3) make_filesystems;;
        4) make_internet;;
        5) initial_install;;
        6) generate_fstab;;
        7) chroot_configuration;;
        8) finishup;;
        9) exiting_installer;;
    esac
}

list_partitions() {
    #partition_list=`blkid | grep -i 'TYPE="ext[234]"' | cut -d ' ' -f 1 | grep -i '^/dev/' | grep -v '/dev/loop' | grep -v '/dev/mapper' | sed "s/://g"`
    fdisk -l | grep Linux | cut -b 1-9 > $TMP/pout 2>/dev/null
    partition_list=$(cat $TMP/pout)
    if [ "$partition_list" = "" ] ; then
        partition_list="It appears you have no linux partitions yet."
    fi

    dialog --clear --backtitle "$upper_title" --title "Partitions" --msgbox "$partition_list \n\n Hit enter to return to menu" 15 40
}

partition_editor() {
    dialog --clear --backtitle "$upper_title" --title "Partition editor" --cancel-label "Cancel" --msgbox "pdq is not responsible for loss of data or anything else. When in doubt, cancel and read the code.\n\nIf you accept this, you can start cfdisk now!\n\nYou can return to the main menu at any time by hitting <ESC> key." 20 70
    if [ $? = 255 ] ; then
        installer_menu
        return 0            
    fi

    dialog --clear --backtitle "$upper_title" --title "Partition editor" --yesno "Create a / (primary, bootable* and recommended minimum 6GB in size) and a /home (primary and remaining size) partition.\n\n* Optionally create a /swap (primary and recommended twice the size of your onboard RAM) and /boot (primary, bootable and recommended minimum 1GB in size) partition.\n\nJust follow the menu, store your changes and quit cfdisk to go on!\n\nIMPORTANT: Read the instructions and the output of cfdisk carefully.\n\nProceed?" 20 70
    if [ $? = 0 ] ; then
        umount /mnt/* 2>/dev/null
        cfdisk
    fi
}

make_filesystems() {
    fdisk -l | grep Linux | sed -e '/swap/d' | cut -b 1-9 > $TMP/pout 2>/dev/null

    dialog --clear --backtitle "$upper_title" --title "ROOT PARTITION DETECTED" --exit-label OK --msgbox "Installer has detected\n\n `cat /tmp/tmp/pout` \n\n as your linux partition(s).\n\nIn the next box you can choose the linux filesystem for your root partition or choose the partition if you have more linux partitions!" 20 70
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi

    # choose root partition
    dialog --clear --backtitle "$upper_title" --title "CHOOSE ROOT PARTITION" --inputbox "Please choose your preferred root partition in this way:\n\n/dev/hdaX --- X = number of the partition, e. g. 1 for /dev/hda1!" 10 70 2> $TMP/pout
    if [ $? = 1 ] || [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi

    pout=$(cat $TMP/pout)

    dialog --clear --backtitle "$upper_title" --title "ROOT  PARTITION" --yesno "Create the filesystem? [Select No to skip to mounting]" 20 70
    if [ $? = 0 ] ; then
        dialog --clear --backtitle "$upper_title" --title "FORMAT ROOT PARTITION" --radiolist "Now you can choose the filesystem for your root partition.\n\next4 is the recommended filesystem." 20 70 30 \
        "1" "ext2" off \
        "2" "ext3" off \
        "3" "ext4" on \
        2> $TMP/part
        if [ $? = 1 ] || [ $? = 255 ] ; then
            installer_menu
            return 0 
        fi

        part=$(cat $TMP/part)
        fs_type=

        if [ "$part" == "2" ] ; then
            fs_type="ext3"
        elif [ "$part" == "3" ] ; then
            fs_type="ext4"
        else
            fs_type="ext2"
        fi

        mkfs -t $fs_type $pout
        typefs=" as $fs_type"
    fi

    mount $pout /mnt

    dialog --clear --backtitle "$upper_title" --title "ROOT PARTITION MOUNTED" --msgbox "Your $pout partition has been mounted at /mnt$typefs" 10 70
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi

    # choose home partition
    dialog --clear --backtitle "$upper_title" --title "CHOOSE HOME PARTITION" --inputbox "Please choose your preferred home partition in this way:\n\n/dev/hdaX --- X = number of the partition, e. g. 2 for /dev/hda2!" 10 70 2> $TMP/plout
    if [ $? = 1 ] || [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi
    
    plout=$(cat $TMP/plout)

    dialog --clear --backtitle "$upper_title" --title "HOME  PARTITION" --yesno "Create the filesystem? [Select No to skip to mounting]" 20 70
    if [ $? = 0 ] ; then
        dialog --clear --backtitle "$upper_title" --title "FORMAT HOME PARTITION" --radiolist "Now you can choose the filesystem for your home partition.\n\next4 is the recommended filesystem." 20 70 30 \
        "1" "ext2" off \
        "2" "ext3" off \
        "3" "ext4" on \
        2> $TMP/plart
        if [ $? = 1 ] || [ $? = 255 ] ; then
            installer_menu
            return 0 
        fi

        plart=$(cat $TMP/plart)
        fs_type=

        if [ "$plart" == "2" ] ; then
            fs_type="ext3"
        elif [ "$plart" == "3" ] ; then
            fs_type="ext4"
        else
            fs_type="ext2"
        fi

        mkdir -vp /mnt/home
        mkfs -t $fs_type $plout
        typefs=" as $fs_type"
    fi

    mount $plout /mnt/home

    dialog --clear --backtitle "$upper_title" --title "HOME PARTITION MOUNTED" --msgbox "Your $plout partition has been mounted at /mnt/home$typefs" 10 70


    dialog --clear --backtitle "$upper_title" --title "BOOT  PARTITION" --defaultno --yesno "Create the boot filesystem?" 20 70
    if [ $? = 0 ] ; then
        # choose boot partition
        dialog --clear --backtitle "$upper_title" --title "CHOOSE BOOT PARTITION" --inputbox "Please choose your preferred boot partition in this way:\n\n/dev/hdaX --- X = number of the partition, e. g. 3 for /dev/hda3!" 10 70 2> $TMP/pbout
        if [ $? = 1 ] || [ $? = 255 ] ; then
            installer_menu
            return 0 
        fi
        
        pbout=$(cat $TMP/pbout)

        dialog --clear --backtitle "$upper_title" --title "BOOT PARTITION" --yesno "Create the filesystem? [Select No to skip to mounting]" 20 70
        if [ $? = 0 ] ; then
            dialog --clear --backtitle "$upper_title" --title "FORMAT BOOT PARTITION" --radiolist "Now you can choose the filesystem for your boot partition.\n\next4 is the recommended filesystem." 20 70 30 \
            "1" "ext2" off \
            "2" "ext3" off \
            "3" "ext4" on \
            2> $TMP/pbart
            if [ $? = 1 ] || [ $? = 255 ] ; then
                installer_menu
                return 0 
            fi

            pbart=$(cat $TMP/pbart)
            fs_type=

            if [ "$pbart" == "2" ] ; then
            fs_type="ext3"
            elif [ "$pbart" == "3" ] ; then
            fs_type="ext4"
            else
            fs_type="ext2"
            fi

            mkdir -vp /mnt/boot
            mkfs -t $fs_type $pbout
            typefs=" as $fs_type"
        fi
        mount $pbout /mnt/boot
        ##mount $pbout /mnt/etc

        dialog --clear --backtitle "$upper_title" --title "BOOT PARTITION MOUNTED" --msgbox "Your $pbout partition has been mounted at /mnt/boot$typefs" 10 70
    fi

    dialog --clear --backtitle "$upper_title" --title "SWAP PARTITION" --defaultno --yesno "Create the swap filesystem?" 10 70
    if [ $? = 0 ] ; then
        # choose home partition
        dialog --clear --backtitle "$upper_title" --title "CHOOSE SWAP PARTITION" --inputbox "Please choose your preferred swap partition in this way:\n\n/dev/hdaX --- X = number of the partition, e. g. 4 for /dev/hda4!" 10 70 2> $TMP/psout
        psout=$(cat $TMP/psout)
        mkswap $psout
        swapon $psout
        dialog --clear --backtitle "$upper_title" --title "SWAP SETUP" --msgbox "Ran: mkswap $psout and swapon $psout" 10 70
    fi
}

make_internet() {
    dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Test/configure internet connection" 10 70
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi

    dialog --clear --backtitle "$upper_title" --title "Internet" --yesno "Configure wired connection?" 10 70
    if [ $? = 0 ] ; then
        local net_list mynet
        for mynet in $(ip link show | awk '/: / {print $2}' | tr -d :) ; do
            net_list+="${mynet} - "
        done

        my_networks=$(dialog --stdout --backtitle "$upper_title" --title 'Internet' --cancel-label "Go Back" \
        --default-item "${my_networks}" --menu "Choose network or <Go Back> to return" 16 45 23 ${net_list} "Exit" "-" || echo "${my_networks}")

        if [ "$my_networks" = "" ] || [ $? = 255 ] || [ "$my_networks" = "Exit" ] ; then
            installer_menu
            return 0
        fi

        if [ "$my_networks" ] ; then # some better check should be here / placeholder
            #dhcpcd $my_networks
            if [ -f /usr/bin/netctl ]; then
                mkdir create_network && cd create_network
                wget http://www.opennicproject.org/nearest-servers/
                dns_ip1=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' index.html | sort -r | head -1)
                dns_ip2=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' index.html | sort -rg | head -1)
                cp /etc/netctl/examples/ethernet-static /etc/netctl/ethernetstatic
                sed -i "s/eth0/$my_networks/g" /etc/netctl/ethernetstatic
                echo "DNS=('$dns_ip1' '$dns_ip2')" >> /etc/netctl/ethernetstatic
                netctl start ethernetstatic
                netctl enable ethernetstatic
                cd .. && rm -r create_network
            else
                dhcpcd $my_networks
            fi

            dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Set network to $my_networks using netctl (enabled/started)" 10 30
        else
            dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Failed to set network...network does not exist/null?" 10 30
        fi

        # wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null

        # if [ ! -s /tmp/index.google ] ; then
        #     dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "It appears you have no internet connection, refer to for instructions on loading your required wireless kernel modules.\n\nhttps://wiki.archlinux.org/index.php/Wireless_Setup" 10 40
        # else
        #     dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "It appears you have an internet connection, huzzah for small miracles. :p" 10 30
        # fi
    else
        dialog --clear --backtitle "$upper_title" --title "Internet" --radiolist "Choose your preferred wireless setup tool" 10 70 30 \
        "1" "wifi-menu" on \
        "2" "wpa_supplicant" off \
        2> $TMP/pwifi
        if [ $? = 1 ] || [ $? = 255 ] ; then
            installer_menu
            return 0 
        fi

        local net_list mynet
        for mynet in $(ip link show | awk '/: / {print $2}' | tr -d :) ; do
            net_list+="${mynet} - "
        done

        my_networks=$(dialog --stdout --backtitle "$upper_title" --title 'Internet' --cancel-label "Go Back" \
        --default-item "${my_networks}" --menu "Choose network or <Go Back> to return" 16 45 23 ${net_list} "Exit" "-" || echo "${my_networks}")

        if [ "$my_networks" = "" ] || [ $? = 255 ] || [ "$my_networks" = "Exit" ] ; then
            installer_menu
            return 0
        fi

        if [ "$my_networks" ] ; then # some better check should be here / placeholder
            dhcpcd $my_networks
            dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Set network to $my_networks" 10 30
        else
            dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Failed to set network...network does not exist/null?" 10 30
        fi

        pwifi=$(cat $TMP/pwifi)
        if [ "$pwifi" == "1" ] ; then
            if [ -f /usr/bin/netctl ]; then
                wifi-menu $my_networks
            else
                dhcpcd $my_networks
            fi
        else
            dialog --clear --backtitle "$upper_title" --title "Internet" --inputbox "Please enter your SSID" 10 70 2> $TMP/pssid
            pssid=$(cat $TMP/pssid)

            dialog --clear --backtitle "$upper_title" --title "Internet" --passwordbox "Please enter your wireless passphrase" 10 70 2> $TMP/ppassphrase
            ppassphrase=$(cat $TMP/ppassphrase)
            wpa_passphrase "$pssid" "$ppassphrase" >> /etc/wpa_supplicant.conf
            wpa_supplicant -B -Dwext -i $my_networks -c /etc/wpa_supplicant.conf & >/dev/null
        fi

        #dhcpcd $my_networks
        # wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
        # if [ ! -s /tmp/index.google ] ; then
        #     dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "It appears you have no internet connection, refer to for instructions on loading your required wireless kernel modules.\n\nhttps://wiki.archlinux.org/index.php/Wireless_Setup" 20 30
        # else
        #     dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "It appears you have an internet connection, huzzah for small miracles. :p" 10 30
        # fi
    fi

    dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Internet configuration complete.\n\n Hit enter to return to menu" 10 30
}

initial_install() {
    dialog --clear --backtitle "$upper_title" --title "Initial install" --msgbox "Install packages" 10 30
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi
    
    echo "" > $TMP/ppkgs
    dialog --clear --backtitle "$upper_title" --title "Custom packages" --inputbox "Please enter any packages you would like added to the initial system installation.\n\nSeperate multiple packages with a space.\n\nIf you do not wish to add any packages beyond the default\nleave input blank and continue." 40 70 2> $TMP/ppkgs
    ppkgs=" $(cat $TMP/ppkgs)"


    if [ "$archtype" = "x86_64" ]; then
        pacman_conf="pacman-x86_64.conf"
        mainpkgs="packages.x86_64"
    else
        mainpkgs="packages.i686"
        pacman_conf="pacman-i686.conf"
    fi

    basepkgs="packages.both"
    
    mv -v /mnt/etc/pacman.conf /mnt/etc/pacman.conf.bak
    mkdir -vp /mnt/etc/pacman.d
    cp -vr /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/
    cp -v /etc/$pacman_conf /etc/pacman.conf
    cp -v /etc/$pacman_conf /mnt/etc/pacman.conf
    sed -i "s/repo.mooOS.pdq/69.197.166.101\/repos/g" /mnt/etc/pacman.conf

    dialog --clear --backtitle "$upper_title" --title "Packages" --yesno "Do you wish to use socks5 proxy for pacman? (Default: yes)" 10 30
    if [ $? = 0 ] ; then
        sed -i "s/#XferCommand = \/usr\/bin\/curl -C - -f %u > %o/XferCommand = \/usr\/bin\/curl --socks5-hostname localhost:9050 -C - -f %u > %o/g" /mnt/etc/pacman.conf
    fi
    

    pacstrap  /mnt base base-devel sudo git rsync wget dialog zsh$ppkgs $(cat /home/moo/Github/mooOS-dev-tools/$basepkgs) $(cat /home/moo/Github/mooOS-dev-tools/$mainpkgs)
    #pacstrap /mnt base base-devel sudo git rsync wget zsh$ppkgs

    PWD=$(pwd)

    cp -v /etc/$pacman_conf /mnt/etc/pacman.conf
    sed -i "s/repo.mooOS.pdq/69.197.166.101\/repos/g" /mnt/etc/pacman.conf
    cp -v /etc/psd.conf /mnt/etc/psd.conf
    cp -v /etc/issue /mnt/etc/issue
    cp -v /etc/lsb-release /mnt/etc/lsb-release
    cp -v /etc/os-release /mnt/etc/os-release
    mkdir -vp /mnt/etc/tor
    cp -vr /etc/tor/* /mnt/etc/tor/
    cp -vr /etc/systemd/system/* /mnt/etc/systemd/system/
    
    mkdir -vp /mnt/etc/privoxy
    sh -c "echo 'forward-socks5 / localhost:9050 .' > /mnt/etc/privoxy/config"

    mkdir -vp /mnt/etc/dansguardian
    cp -v /etc/dansguardian/dansguardian.conf /mnt/etc/dansguardian/dansguardian.conf

    mkdir -vp /mnt/etc/squid
    cp -v /etc/squid/squid.conf /mnt/etc/squid/squid.conf

    mkdir -vp /mnt/etc/pacserve
    cp -vr /etc/pacserve/* /mnt/etc/pacserve/

    mkdir -vp /mnt/etc/modules-load.d
    cp -vr /etc/modules-load.d/* /mnt/etc/modules-load.d/

    mkdir -vp /mnt/etc/grub.d
    cp -vr /etc/grub.d/* /mnt/etc/grub.d/

    mkdir -vp /mnt/etc/default
    cp -vr /etc/default/* /mnt/etc/default/

    mkdir -vp /mnt/usr/share/nano
    cp -v /usr/share/nano/pkgbuild.nanorc /mnt/usr/share/nano/pkgbuild.nanorc

    mkdir -vp /mnt/usr/share/enlightenment/data/backgrounds
    cp -v /usr/share/enlightenment/data/backgrounds/* /mnt/usr/share/enlightenment/data/backgrounds

    mkdir -vp /mnt/usr/share/enlightenment/data/themes
    cp -v /usr/share/enlightenment/data/themes/* /mnt/usr/share/enlightenment/data/themes

    #mv -v /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
    #cp -v ${dev_directory}etc/httpd.conf /etc/httpd/conf/httpd.conf
    #cp -v ${dev_directory}etc/httpd-phpmyadmin.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
    #mv -v /etc/php/php.ini /etc/php/php.ini.bak
    #cp -v ${dev_directory}etc/php.ini /etc/php/php.ini

    # copy over custom .desktop files
    mkdir -vp /mnt/usr/share/applications
    cp -v /usr/share/applications/*.desktop /mnt/usr/share/applications/
    
    ## https://github.com/dmatarazzo/Sublime-Text-2-Icon
    echo "Updating Sublime Text 3 icons"
    cp -v /usr/share/icons/HighContrast/16x16/apps/sublime-text.png /mnt/usr/share/icons/HighContrast/16x16/apps/sublime-text.png
    cp -v /usr/share/icons/HighContrast/256x256/apps/sublime-text.png /mnt/usr/share/icons/HighContrast/256x256/apps/sublime-text.png
    cp -v /usr/share/icons/HighContrast/32x32/apps/sublime-text.png /mnt/usr/share/icons/HighContrast/32x32/apps/sublime-text.png
    cp -v /usr/share/icons/HighContrast/48x48/apps/sublime-text.png /mnt/usr/share/icons/HighContrast/48x48/apps/sublime-text.png
    cp -v /usr/share/icons/gnome/16x16/apps/sublime-text.png /mnt/usr/share/icons/gnome/16x16/apps/sublime-text.png
    cp -v /usr/share/icons/gnome/256x256/apps/sublime-text.png /mnt/usr/share/icons/gnome/256x256/apps/sublime-text.png
    cp -v /usr/share/icons/gnome/32x32/apps/sublime-text.png /mnt/usr/share/icons/gnome/32x32/apps/sublime-text.png
    cp -v /usr/share/icons/gnome/48x48/apps/sublime-text.png /mnt/usr/share/icons/gnome/48x48/apps/sublime-text.png
    cp -v /usr/share/icons/hicolor/128x128/apps/sublime-text.png /mnt/usr/share/icons/hicolor/128x128/apps/sublime-text.png
    cp -v /usr/share/icons/hicolor/16x16/apps/sublime-text.png /mnt/usr/share/icons/hicolor/16x16/apps/sublime-text.png
    cp -v /usr/share/icons/hicolor/256x256/apps/sublime-text.png /mnt/usr/share/icons/hicolor/256x256/apps/sublime-text.png
    cp -v /usr/share/icons/hicolor/32x32/apps/sublime-text.png /mnt/usr/share/icons/hicolor/32x32/apps/sublime-text.png
    cp -v /usr/share/icons/hicolor/48x48/apps/sublime-text.png /mnt/usr/share/icons/hicolor/48x48/apps/sublime-text.png
    cp -v /usr/share/icons/oxygen/128x128/apps/sublime-text.png /mnt/usr/share/icons/oxygen/128x128/apps/sublime-text.png
    cp -v /usr/share/icons/oxygen/16x16/apps/sublime-text.png /mnt/usr/share/icons/oxygen/16x16/apps/sublime-text.png
    cp -v /usr/share/icons/oxygen/256x256/apps/sublime-text.png /mnt/usr/share/icons/oxygen/256x256/apps/sublime-text.png
    cp -v /usr/share/icons/oxygen/32x32/apps/sublime-text.png /mnt/usr/share/icons/oxygen/32x32/apps/sublime-text.png
    cp -v /usr/share/icons/oxygen/48x48/apps/sublime-text.png /mnt/usr/share/icons/oxygen/48x48/apps/sublime-text.png

    ## mooOS icon
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-16.png /mnt/usr/share/icons/HighContrast/16x16/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-256.png /mnt/usr/share/icons/HighContrast/256x256/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-32.png /mnt/usr/share/icons/HighContrast/32x32/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-48.png /mnt/usr/share/icons/HighContrast/48x48/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-16.png /mnt/usr/share/icons/gnome/16x16/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-256.png /mnt/usr/share/icons/gnome/256x256/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-32.png /mnt/usr/share/icons/gnome/32x32/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-48.png /mnt/usr/share/icons/gnome/48x48/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-128.png /mnt/usr/share/icons/hicolor/128x128/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-16.png /mnt/usr/share/icons/hicolor/16x16/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-256.png /mnt/usr/share/icons/hicolor/256x256/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-32.png /mnt/usr/share/icons/hicolor/32x32/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-48.png /mnt/usr/share/icons/hicolor/48x48/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-128.png /mnt/usr/share/icons/oxygen/128x128/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-16.png /mnt/usr/share/icons/oxygen/16x16/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-256.png /mnt/usr/share/icons/oxygen/256x256/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-32.png /mnt/usr/share/icons/oxygen/32x32/apps/mooOS.png
    cp -v /home/moo/Github/mooOS-dev-tools/images/mooOS-48.png /mnt/usr/share/icons/oxygen/48x48/apps/mooOS.png
    
    # create ~/Github and all repos
    rm -rf /mnt/etc/skel/Github
    mkdir -vp /mnt/etc/skel/Github
    cd /mnt/etc/skel/Github
    git clone git://github.com/idk/pdq.git
    git clone git://github.com/idk/bin.git
    #git clone git://github.com/idk/awesomewm-X.git
    git clone git://github.com/idk/zsh.git
    git clone git://github.com/idk/bin.git
    git clone git://github.com/idk/php.git
    git clone git://github.com/idk/systemd.git
    git clone git://github.com/idk/eggdrop-scripts.git
    git clone git://github.com/idk/gh.git
    git clone git://github.com/idk/vb-pdq.git
    git clone git://github.com/idk/mooOS-dev-tools.git
    git clone git://github.com/idk/mooOS-wallpapers.git
    cd "$PWD"

    install -Dm644 "/mnt/etc/skel/Github/mooOS-dev-tools/misc/man.1" "/mnt/usr/local/man/man1/mooOS.1"
    gzip -f /mnt/usr/local/man/man1/mooOS.1
}

chroot_configuration() {
    dialog --clear --backtitle "$upper_title" --title "Chroot" --msgbox "Chroot into mounted filesystem" 10 30 
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi
     
    #if [ ! -f /mnt/chroot-install_mooOS ]; then
    #wget https://raw.github.com/idk/pdq/master/chroot-install_mooOS -O chroot-install_mooOS
    mkdir -vp /mnt/etc/skel/Github/mooOS-dev-tools/installer
    cp /home/moo/Github/mooOS-dev-tools/installer/chroot-install.sh /mnt/etc/skel/Github/mooOS-dev-tools/installer/chroot-install.sh
    chmod +x /mnt/etc/skel/Github/mooOS-dev-tools/installer/chroot-install.sh

    cp /etc/resolv.conf /mnt/etc/resolv.conf
    cp -vr /etc/skel /mnt/etc/
    cp -v /etc/arch-release /mnt/etc/arch-release

    # fix missing icons in .desktop files
    sed -i "s/Icon=mediadownloader/Icon=mplayer/g" /mnt/usr/share/applications/mediadownloader.desktop
    #sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukbackup.desktop
    #sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukcleaner.desktop
    #sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukcontroller.desktop
    sed -i "s/Exec=/Exec=kdesudo /g" /mnt/usr/share/applications/gparted.desktop

    if [ -f /mnt/usr/share/applications/kde4/nepomukcleaner.desktop ]; then
        rm /mnt/usr/share/applications/kde4/nepomukcleaner.desktop
    fi

    if [ -f /mnt/usr/share/applications/kde4/nepomukbackup.desktop ]; then
        rm /mnt/usr/share/applications/kde4/nepomukbackup.desktop
    fi

    if [ -f /mnt/usr/share/applications/feh.desktop ]; then
        rm /mnt/usr/share/applications/feh.desktop
    fi

    if [ -f /mnt/usr/share/applications/kde4/nepomukcontroller.desktop ]; then
        rm /mnt/usr/share/applications/kde4/nepomukcontroller.desktop
    fi

    if [ -f /mnt/usr/share/applications/enlightenment_filemanager.desktop ]; then
        rm /mnt/usr/share/applications/enlightenment_filemanager.desktop
    fi

    if [ -f /mnt/usr/share/applications/avahi-discover.desktop ]; then
        rm /mnt/usr/share/applications/avahi-discover.desktop
    fi

    if [ -f /mnt/usr/share/applications/bssh.desktop ]; then
        rm /mnt/usr/share/applications/bssh.desktop
    fi

    if [ -f /mnt/usr/share/applications/bvnc.desktop ]; then
        rm /mnt/usr/share/applications/bvnc.desktop
    fi

    if [ -f /mnt/usr/share/enlightenment/data/themes/Post_It_White.edj ]; then
        rm -f /mnt/usr/share/enlightenment/data/themes/Post_It_White.edj
    fi

    if [ -f /mnt/usr/share/enlightenment/data/themes/Simply_White_etk.edj ]; then
        rm -f /mnt/usr/share/enlightenment/data/themes/Simply_White_etk.edj
    fi

    if [ -f /mnt/usr/share/enlightenment/data/themes/New_Millenium.edj ]; then
        rm -f /mnt/usr/share/enlightenment/data/themes/New_Millenium.edj
    fi

    if [ -f /mnt/usr/share/enlightenment/data/themes/qv4l2.desktop ]; then
        rm -f /mnt/usr/share/enlightenment/data/themes/qv4l2.desktop
    fi

    export TERM=xterm-color && arch-chroot /mnt /bin/sh -c "/etc/skel/Github/mooOS-dev-tools/installer/chroot-install.sh"
}

generate_fstab() {
    dialog --clear --backtitle "$upper_title" --title "fstab configuration" --msgbox "Generate fstab" 10 30
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi
   
    genfstab -U -p /mnt >> /mnt/etc/fstab
    dialog --clear --backtitle "$upper_title" --title "fstab configuration" --yesno "Do you wish to view/edit this file?" 10 30
    if [ $? = 0 ] ; then
        nano /mnt/etc/fstab
    fi
    
    dialog --clear --backtitle "$upper_title" --title "fstab configuration" --msgbox "Hit enter to return to menu" 10 30
}

finishup() {
    dialog --clear --backtitle "$upper_title" --title "Finishing up" --msgbox "Finish install and reboot" 10 30
    if [ $? = 255 ] ; then
        installer_menu
        return 0 
    fi
    
    dialog --clear --backtitle "$upper_title" --title "Finishing up" --msgbox "mooOS has been installed!\n\nAfter reboot, to complete install of mooOS:\n\nlogin as your created user.\n\nSee ya!" 30 60

    umount /mnt/* 2>/dev/null
    umount /mnt 2>/dev/null
    reboot
}

# utility execution
while true
do
    installer_menu
done

#DEBUG
#echo "end of script"
#sleep 2s
