#!/bin/bash
## chroot-install.sh sub-script for chroot fo mooOS =)
## 08-27-2013 pdq

upper_title="[ mooOS environment configuration ] (chroot)"

## only allow root to run script
if [ $(id -u) -eq 0 ]; then

    ## sanity default checks
    # wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
    # if [ ! -s /tmp/index.google ] ; then
    #     systemctl enable dhcpcd@eth0.service
    # fi

    # wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
    # if [ ! -s /tmp/index.google ] ; then
    #     echo "It appears you have no internet connectivity.\n\nRead: https://wiki.archlinux.org/index.php/Configuring_network"
    #     echo "This script will exit in 1 minute... or press ctrl-c to exit now."
    #     sleep 60s
    #     exit 0
    # fi

    ## styling
    clr=""

    ## temporary files
    _TEMP=/tmp/chanswer$$
    mkdir -p /tmp/tmp 2>/dev/null
    TMP=/tmp/tmp 2>/dev/null
    echo "unset" > $TMP/rootpasswd

    _CURRENT=/tmp/current
    echo "8" > $_CURRENT

    _CCURRENT=/tmp/ccurrent
    echo "1" > $_CCURRENT

    #setterm -blank 0
    #pacman -Syy
    #pacman -S --noconfirm --needed dialog

    ## functions
    exiting() {
        clear
        rm -f $_TEMP
        dialog --clear --backtitle "$upper_title" --title "[ Return to Installer ]" --msgbox "Proceed." 10 30
        exit 0
        exit 0
    }

    current_selection() {
    echo "$1" > $_CCURRENT
}

    gen_tz() {
        dialog --clear --backtitle "$upper_title" --title "[ TIMEZONE ]" --msgbox "Generate timezone/localtime" 10 40
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        local tz_list tz
        for tz in $(grep -v "#" /usr/share/zoneinfo/zone.tab | awk '{print $3}' | sort) ; do
            tz_list+="${tz} - "
        done

        GEN_TIMEZONE=$(dialog --stdout --backtitle "${upper_title}" --title '[ TIMEZONE ]' --cancel-label "Go Back" \
           --default-item "${GEN_TIMEZONE}" --menu "Choose timezone or <Go Back> to return" 16 40 23 ${tz_list} "null" "-" || echo "${GEN_TIMEZONE}")

        if [ "$GEN_TIMEZONE" = "" ] ; then
            chroot_menu
            return 0
        fi

        if [ -f "/usr/share/zoneinfo/$GEN_TIMEZONE" ] ; then
            ln -s /usr/share/zoneinfo/$GEN_TIMEZONE /etc/localtime
            dialog --clear --backtitle "$upper_title" --title "[ TIMEZONE ]" --msgbox "Set timezone to $GEN_TIMEZONE" 10 30
        else
            dialog --clear --backtitle "$upper_title" --title "[ TIMEZONE ]" --msgbox "Failed to set timezone...timezone does not exist?" 10 30
        fi
        current_selection 3
    }

    gen_hostname() {
        dialog --clear --backtitle "$upper_title" --title "[ HOSTNAME ]" --msgbox "Generate hostname" 10 30
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        GEN_HOSTNAME=$(dialog --stdout --backtitle "${upper_title}" --title '[ HOSTNAME ]' --cancel-label "Go Back" \
           --inputbox "Enter desired hostname or <Go Back> to return" 9 40 "${GEN_HOSTNAME}" || echo "${GEN_HOSTNAME}")
      
        if [ "$GEN_HOSTNAME" = "" ] ; then
            chroot_menu
            return 0
        fi

        echo $GEN_HOSTNAME > /etc/hostname
        dialog --clear --backtitle "$upper_title" --title "[ HOSTNAME ]" --msgbox "Set hostname to $GEN_HOSTNAME" 10 30
        current_selection 2
    }

    gen_locale() {
        dialog --clear --backtitle "$upper_title" --title "[ LOCALES ]" --msgbox "Generate locale" 10 30
        
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        GEN_LANG=$(dialog --stdout --backtitle "${upper_title}" --title '[ LOCALES ]' --cancel-label "Go Back" --default-item "${GEN_LANG}" \
           --menu "Choose a locale or <Go Back> to return" 16 40 23 \
            en_US.UTF-8 - \
            en_AU.UTF-8 - \
            en_BW.UTF-8 - \
            en_CA.UTF-8 - \
            en_DK.UTF-8 - \
            en_GB.UTF-8 - \
            en_HK.UTF-8 - \
            en_IE.UTF-8 - \
            en_NZ.UTF-8 - \
            en_PH.UTF-8 - \
            en_SG.UTF-8 - \
            en_US.UTF-8 - \
            en_ZA.UTF-8 - \
            en_ZW.UTF-8 - \
            aa_DJ.UTF-8 - \
            af_ZA.UTF-8 - \
            an_ES.UTF-8 - \
            ar_AE.UTF-8 - \
            ar_BH.UTF-8 - \
            ar_DZ.UTF-8 - \
            ar_EG.UTF-8 - \
            ar_IQ.UTF-8 - \
            ar_JO.UTF-8 - \
            ar_KW.UTF-8 - \
            ar_LB.UTF-8 - \
            ar_LY.UTF-8 - \
            ar_MA.UTF-8 - \
            ar_OM.UTF-8 - \
            ar_QA.UTF-8 - \
            ar_SA.UTF-8 - \
            ar_SD.UTF-8 - \
            ar_SY.UTF-8 - \
            ar_TN.UTF-8 - \
            ar_YE.UTF-8 - \
            ast_ES.UTF-8 - \
            be_BY.UTF-8 - \
            bg_BG.UTF-8 - \
            br_FR.UTF-8 - \
            bs_BA.UTF-8 - \
            ca_AD.UTF-8 - \
            ca_ES.UTF-8 - \
            ca_FR.UTF-8 - \
            ca_IT.UTF-8 - \
            cs_CZ.UTF-8 - \
            cy_GB.UTF-8 - \
            da_DK.UTF-8 - \
            de_AT.UTF-8 - \
            de_BE.UTF-8 - \
            de_CH.UTF-8 - \
            de_DE.UTF-8 - \
            de_LU.UTF-8 - \
            el_CY.UTF-8 - \
            el_GR.UTF-8 - \
            es_AR.UTF-8 - \
            es_BO.UTF-8 - \
            es_CL.UTF-8 - \
            es_CO.UTF-8 - \
            es_CR.UTF-8 - \
            es_DO.UTF-8 - \
            es_EC.UTF-8 - \
            es_ES.UTF-8 - \
            es_GT.UTF-8 - \
            es_HN.UTF-8 - \
            es_MX.UTF-8 - \
            es_NI.UTF-8 - \
            es_PA.UTF-8 - \
            es_PE.UTF-8 - \
            es_PR.UTF-8 - \
            es_PY.UTF-8 - \
            es_SV.UTF-8 - \
            es_US.UTF-8 - \
            es_UY.UTF-8 - \
            es_VE.UTF-8 - \
            et_EE.ISO-8859-15 - \
            et_EE.UTF-8 - \
            eu_ES.UTF-8 - \
            fi_FI.UTF-8 - \
            fo_FO.UTF-8 - \
            fr_BE.UTF-8 - \
            fr_CA.UTF-8 - \
            fr_CH.UTF-8 - \
            fr_FR.UTF-8 - \
            fr_LU.UTF-8 - \
            ga_IE.UTF-8 - \
            gd_GB.UTF-8 - \
            gl_ES.UTF-8 - \
            gv_GB.UTF-8 - \
            he_IL.UTF-8 - \
            hr_HR.UTF-8 - \
            hsb_DE.UTF-8 - \
            hu_HU.UTF-8 - \
            hy_AM.ARMSCII-8 - \
            id_ID.UTF-8 - \
            is_IS.UTF-8 - \
            it_CH.UTF-8 - \
            it_IT.UTF-8 - \
            iw_IL.UTF-8 - \
            ja_JP.EUC-JP - \
            ja_JP.UTF-8 - \
            ka_GE.UTF-8 - \
            kk_KZ.UTF-8 - \
            kl_GL.UTF-8 - \
            ko_KR.EUC-KR - \
            ko_KR.UTF-8 - \
            ku_TR.UTF-8 - \
            kw_GB.UTF-8 - \
            lg_UG.UTF-8 - \
            lt_LT.UTF-8 - \
            lv_LV.UTF-8 - \
            mg_MG.UTF-8 - \
            mi_NZ.UTF-8 - \
            mk_MK.UTF-8 - \
            ms_MY.UTF-8 - \
            mt_MT.UTF-8 - \
            nb_NO.UTF-8 - \
            nl_BE.UTF-8 - \
            nl_NL.UTF-8 - \
            nn_NO.UTF-8 - \
            oc_FR.UTF-8 - \
            om_KE.UTF-8 - \
            pl_PL.UTF-8 - \
            pt_BR.UTF-8 - \
            pt_PT.UTF-8 - \
            ro_RO.UTF-8 - \
            ru_RU.KOI8-R - \
            ru_RU.UTF-8 - \
            ru_UA.UTF-8 - \
            sk_SK.UTF-8 - \
            sl_SI.UTF-8 - \
            so_DJ.UTF-8 - \
            so_KE.UTF-8 - \
            so_SO.UTF-8 - \
            sq_AL.UTF-8 - \
            st_ZA.UTF-8 - \
            sv_FI.UTF-8 - \
            sv_SE.UTF-8 - \
            tg_TJ.UTF-8 - \
            th_TH.UTF-8 - \
            tl_PH.UTF-8 - \
            tr_CY.UTF-8 - \
            tr_TR.UTF-8 - \
            uk_UA.UTF-8 - \
            vi_VN.TCVN - \
            wa_BE.UTF-8 - \
            xh_ZA.UTF-8 - \
            yi_US.UTF-8 - \
            zh_CN.GB18030 - \
            zh_CN.GBK - \
            zh_CN.UTF-8 - \
            zh_HK.UTF-8 - \
            zh_SG.GBK - \
            zh_SG.UTF-8 - \
            zh_TW.EUC-TW - \
            zh_TW.UTF-8 - \
            zu_ZA.UTF-8 - "null" "-" || echo "${GEN_LANG}")
    
        if [ "$GEN_LANG" = "" ] ; then
            chroot_menu
            return 0
        fi

        echo "${GEN_LANG} ${GEN_LANG##*.}" > "/etc/locale.gen"
        echo "LANG=${GEN_LANG}" > "/etc/locale.conf"
        export "LANG=${GEN_LANG}"
        locale-gen 1>/dev/null || echo "Unable to setup the locales to" "${GEN_LANG}"
        dialog --clear --backtitle "$upper_title" --title "[ LOCALES ]" --msgbox "Set locale to ${GEN_LANG}" 10 30
        current_selection 4
    }

    set_root_pass() {
        dialog --clear --backtitle "$upper_title" --title "[ ROOT PASSWD ]" --msgbox "Set root password" 10 30
        
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        passwd
        echo "set" > $TMP/rootpasswd
        dialog --clear --backtitle "$upper_title" --title "[ ROOT PASSWD ]" --msgbox "root password set!" 10 30
        current_selection 5
    }

    add_user() {
        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --msgbox "Create user and add to sudoers" 10 30
        
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --inputbox "Please choose your username:\n\n" 10 70 2> $TMP/puser
        puser=$(cat $TMP/puser)

        useradd -m -g users -s /usr/bin/zsh $puser
        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --msgbox "Next step is to add password for $puser" 10 30
        passwd $puser
        cp /etc/sudoers /etc/sudoers.bak

        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --yesno "Require no password for sudo? [suggested: Yes]" 10 30
        if [ $? = 0 ] ; then
            sh -c "echo '$puser ALL=(ALL) NOPASSWD: ALL' >>  /etc/sudoers"
            npasswd="no password required"
        else
            sh -c "echo '$puser ALL=(ALL) ALL' >>  /etc/sudoers"
            npasswd="password required"
        fi

        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --defaultno --yesno "Confirm/view sudoers?" 10 30
        if [ $? = 0 ] ; then
            EDITOR=nano visudo
        fi

        usermod -s /usr/bin/zsh root

        ## copy this script to user home directory
        # if [ ! -f /home/$puser/install_mooOS_user ]; then
        #     wget http://is.gd/mooOS -O /home/$puser/install_mooOS_user
        #     chown -R $puser /home/$puser/install_mooOS_user
        #     chmod +x /home/$puser/install_mooOS_user
        # fi

        dialog --clear --backtitle "$upper_title" --title "[ CREATE USER ]" --msgbox "Added the user $puser with $npsswd for sudo." 10 30
        current_selection 6
    }

    install_bootloader() {
        dialog --clear --backtitle "$upper_title" --title "[ BOOTLOADER ]" --msgbox "Install Bootloader" 10 30
        if [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi
        
        dialog --clear --backtitle "$upper_title" --title "[ BOOTLOADER ]" --radiolist "Select bootloader" 20 70 30 \
        "1" "grub 2" on \
        "2" "syslinux" off \
        2> $TMP/pbootloader
        if [ $? = 1 ] || [ $? = 255 ] ; then
            chroot_menu
            return 0
        fi

        pbootloader=$(cat $TMP/pbootloader)
        if [ "$pbootloader" == "1" ] ; then
            dialog --clear --backtitle "$upper_title" --title "[ GRUB 2]" --radiolist "Select grub type" 20 70 30 \
            "1" "grub-bios" on \
            "2" "grub-efi" off \
            2> $TMP/pgrub
            if [ $? = 1 ] || [ $? = 255 ] ; then
                chroot_menu
                return 0
            fi

            pgrub=$(cat $TMP/pgrub)
            if [ "$pgrub" == "1" ] ; then
                pacman -S --noconfirm --needed grub-bios
            else
                pacman -S --noconfirm --needed grub-efi-x86_64
            fi

            # choose boot/root drive
            dialog --clear --backtitle "$upper_title" --title "[ GRUB 2 ]" --inputbox "Please choose the disk to install grub to.\n\n This should be the same drive your boot or root partition is on:\n\nUsually /dev/sda. Be careful!" 10 70 2> $TMP/bout
            if [ $? = 1 ] || [ $? = 255 ] ; then
                chroot_menu
                return 0
            fi

            bout=$(cat $TMP/bout)
            bootmsg="grub-install --target=i386-pc --recheck $bout"
           
            dialog --clear --backtitle "$upper_title" --title "[ GRUB 2 ]" --yesno "Is this correct?\n\n grub-install --target=i386-pc --recheck $bout" 10 30
            if [ $? = 0 ] ; then
                grub-install --target=i386-pc --recheck $bout
                dialog --clear --backtitle "$upper_title" --title "[ GRUB 2 ]" --msgbox "Grub installed" 10 30
    
                dialog --clear --backtitle "$upper_title" --title "[ GRUB CONFIGURE ]" --msgbox "Configure Grub" 10 30
                if [ $? = 1 ] ; then
                    chroot_menu
                    return 0
                fi

                ## TODO
                cp -v /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
                grub-mkconfig -o /boot/grub/grub.cfg
                dialog --clear --backtitle "$upper_title" --title "[ GRUB CONFIGURE ]" --msgbox "Grub configured" 10 30

            else
                dialog --clear --backtitle "$upper_title" --title "[ GRUB 2 ]" --msgbox "Grub not installed..." 10 30
            fi
        else
            pacman -S --noconfirm --needed syslinux
            syslinux-install_update -i -a -m
            dialog --clear --backtitle "$upper_title" --title "[ SYSLINUX ]" --msgbox "Syslinux installed" 10 30
            dialog --clear --backtitle "$upper_title" --title "[ SYSLINUX ]" --defaultno --yesno "Edit/view syslinux.cfg?" 10 30
            if [ $? = 0 ] ; then
                nano /boot/syslinux/syslinux.cfg
            fi
            bootmsg="syslinux @ /boot/syslinux/syslinux.cfg"
        fi
        current_selection 7
    }

    conf_view() {
        echo "HOSTNAME: $(cat /etc/hostname)"
        echo "TIMEZONE: $(readlink /etc/localtime)"
        echo "LOCALE: $(cat /etc/locale.conf)"
        echo "ROOT PASSWORD: $(cat $TMP/rootpasswd)"
        echo "USERS: $(awk -F":" '$7 ~ /\/usr\/bin\/zsh/ {print $1}' /etc/passwd)"
        echo "BOOTLOADER: $bootmsg"
        echo "Returning to menu in 5 seconds..."
        sleep 5s
        dialog --clear --backtitle "$upper_title" --title "[ VIEW CONFIGURATION ]" --msgbox "Return" 10 30
        current_selection 8
    }

    edit_file() {
        dialog --clear --backtitle "$upper_title" --title "[ Edit files ]" --msgbox "Please choose a file to open with nano.\n\nUse the <tab>, <spacebar> and arrow keys to navigate and select file." 10 30

        file_edit=$(dialog --stdout --backtitle "$upper_title" --title "Please select file." --fselect /etc/ 0 0)

        if [ $? = 0 ] ; then
            nano "$file_edit"
            dialog --clear --backtitle "$upper_title" --title "[ Edit files ]" --defaultno --yesno "Edit/view another file?" 10 30
            if [ $? = 0 ] ; then
                edit_file
            else
                chroot_menu
                return 0 
            fi
        else
            chroot_menu
            return 0 
        fi
        current_selection 9
    }

  make_internet() {
        dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Test/configure internet connection" 10 70
        if [ $? = 255 ] ; then
            chroot_menu
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
                chroot_menu
                return 0
            fi

            if [ "$my_networks" ] ; then # some better check should be here / placeholder
                dhcpcd $my_networks
                systemctl start dhcpcd
                systemctl enable dhcpcd

                # if [ -f /usr/bin/netctl ]; then
                #     mkdir create_network && cd create_network
                #     wget http://www.opennicproject.org/nearest-servers/
                #     dns_ip1=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' index.html | sort -r | head -1)
                #     dns_ip2=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' index.html | sort -rg | head -1)
                #     cp /etc/netctl/examples/ethernet-static /etc/netctl/ethernetstatic
                #     sed -i "s/eth0/$my_networks/g" /etc/netctl/ethernetstatic
                #     echo "DNS=('$dns_ip1' '$dns_ip2')" >> /etc/netctl/ethernetstatic
                #     netctl start ethernetstatic
                #     netctl enable ethernetstatic
                #     cd .. && rm -r create_network
                # else
                #     dhcpcd $my_networks
                # fi

                dialog --clear --backtitle "$upper_title" --title "Internet" --msgbox "Set network to $my_networks using dhcpcd (enabled/started)" 10 30
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
                chroot_menu
                return 0 
            fi

            local net_list mynet
            for mynet in $(ip link show | awk '/: / {print $2}' | tr -d :) ; do
                net_list+="${mynet} - "
            done

            my_networks=$(dialog --stdout --backtitle "$upper_title" --title 'Internet' --cancel-label "Go Back" \
            --default-item "${my_networks}" --menu "Choose network or <Go Back> to return" 16 45 23 ${net_list} "Exit" "-" || echo "${my_networks}")

            if [ "$my_networks" = "" ] || [ $? = 255 ] || [ "$my_networks" = "Exit" ] ; then
                chroot_menu
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
        current_selection 10
    }

    make_mooOS() {
        if [ "$puser" != "" ]; then

            my_home="/home/$puser/"
            dev_directory="${my_home}Github/"

            locale-gen
            # wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
            # if [ ! -s /tmp/index.google ] ; then
            #     dhcpcd eth0
            #     systemctl enable dhcpcd@eth0.service
            # fi

            #if [ ! -f /usr/bin/hub ]; then
            #    pacman -S --noconfirm --needed hub
            #fi


            # copy root files
#            sed -i "s/[mooOS-pkgs/#[mooOS-pkgs/g" /mnt/etc/pacman.conf
#             sed -i "s/SigLevel = Never/#SigLevel = Never/g" /mnt/etc/pacman.conf
#             sed -i "s/Server = http:\/\/repo.mooOS/#Server = http:\/\/repo.mooOS/g" /mnt/etc/pacman.conf

#             if [ "$archtype" = "x86_64" ]; then
#                 echo "
# [mooOS-pkgs-64]
# SigLevel = Never
# Server = http://69.197.166.101/repos/mooOS-pkgs-64" >> /etc/pacman.conf
#             else
#                 echo "
# [mooOS-pkgs-32]
# SigLevel = Never
# Server = http://69.197.166.101/repos/mooOS-pkgs-32" >> /etc/pacman.conf
#             fi

            # if [ ! -f /usr/bin/pacaur ]; then
            #     #dialog --title "$upper_title" --msgbox "Installing pacaur" 20 70
            #     pacman -S --noconfirm --needed yajl
            #     pacman -S --noconfirm --needed jshon
            #     pacman -S --noconfirm --needed jansson
            #     su $puser -c "wget https://aur.archlinux.org/packages/pa/packer/PKGBUILD -O /tmp/PKGBUILD && cd /tmp && makepkg -sf PKGBUILD && pacman -U --noconfirm --needed packer* && cd"
            #     su $puser -c "packer -S --noconfirm pacaur"
            # fi

            # if [ ! -f /usr/bin/powerpill ]; then
            #     #dialog --title "$upper_title" --msgbox "Installing powerpill" 20 70
            #     pacman -S --noconfirm --needed python3
            #     su $puser -c "packer -S --noconfirm powerpill"
            # fi

           ## sleep 3s
            #if [ ! -d "${dev_directory}pdq" ]; then
           #     dialog --backtitle "$upper_title" --title "Initial clone" --msgbox "Cloning initial repo to ${dev_directory}mooOS-dev-tools/" 10 30
                # cd ${dev_directory}
                # su $puser -c "git clone git://github.com/idk/mooOS-dev-tools.git"
                # #su $puser -c "git clone idk/etc"
                # cd /home/$puser

                # pacman -Syy
            #fi

        #     if [ ! -f /usr/bin/rsync ]; then
        #         pacman -S --noconfirm rsync
        #     fi

        #     dialog --clear --backtitle "$upper_title" --title "Extra" --yesno "Is this a VirtualBox install?" 10 30
        #     if [ $? = 0 ] ; then
        #         su $puser -c "powerpill -S --noconfirm --needed virtualbox-guest-utils"
        #         sh -c "echo 'vboxguest
        # vboxsf
        # vboxvideo' > /etc/modules-load.d/virtualbox.conf"
        #     fi

        #     ## sanity checks
        #     if [ ! -f /usr/bin/rsync ] || [ ! -f /usr/bin/pacaur ] || [ ! -f /usr/bin/pacman ] || [ ! -f /usr/bin/powerpill ]; then
        #         dialog --backtitle "$upper_title" --title "$upper_title" --msgbox "Hmmm. An ERROR has occured...\n\nPackage depends not met, this installer failed to install one of the following:\nrsync, git, hub, packer, pacaur, pacman or powerpill.\n\nExiting..." 30 70
        #     fi

            # dialog --clear --backtitle "$upper_title" --title "Packages" --yesno "Install main packages?" 10 30
            # if [ $? = 0 ] ; then
            #     dialog --backtitle "$upper_title" --title "$upper_title" --msgbox "When it askes if install 1) phonon-gstreamer or 2) phonon-vlc\nchose 2\n\nWhen it asks if replace foo with bar chose y for everyone" 20 70
            #     su $puser -c "powerpill -Syy"

            #     if [ "$archtype" = "x86_64" ]; then
            #         mainpkgs="packages.x86_64"
            #     else
            #         mainpkgs="packages.i686"
            #     fi

            #     basepkgs="packages.both"

            #     pacman -S --needed $(cat ${dev_directory}mooOS-dev-tools/$basepkgs)

            #     pacman -S --needed $(cat ${dev_directory}mooOS-dev-tools/$mainpkgs)
            # fi

  #          dialog --clear --backtitle "$upper_title" --title "Configuration files" --yesno "Install all repos?" 10 30
  #          if [ $? = 0 ] ; then
                 
                #dialog --clear --title "$upper_title" --msgbox "Backing up and copying root configs" 10 30
                #cp -v ${dev_directory}etc/custom.conf /etc/X11/xorg.conf.d/custom.conf


                # mkdir -p /usr/share/tor/hidden_service1
                # mkdir -p /usr/share/tor/hidden_service2
                # mkdir -p /usr/share/tor/hidden_service3
                # mkdir -p /usr/share/tor/hidden_service4
                # chown -R tor:tor /usr/share/tor/hidden_service1
                # chown -R tor:tor /usr/share/tor/hidden_service2
                # chown -R tor:tor /usr/share/tor/hidden_service3
                # chown -R tor:tor /usr/share/tor/hidden_service4
                # cp ${dev_directory}bin/lamp.sh /usr/bin/lamp

                #systemctl enable dhcpcd@eth0.service
                #systemctl enable NetworkManager.service
                #systemctl enable vnstat.sevice

                systemctl enable multi-user.target pacman-init.service choose-mirror.service
                systemctl enable ntpd.service
                systemctl enable tor.service
                systemctl enable privoxy.service
                systemctl enable preload.service
                systemctl enable polipo.service
                systemctl enable cronie.service
                systemctl enable dhcpcd.service

                dialog --clear --backtitle "$upper_title" --title "Extra" --yesno "Install Apache/MySQL/PHP/PHPMyAdmin  configuration files?" 10 30

                if [ $? = 0 ] ; then

                    $HOSTNAME="$(cat /etc/hostname)"

                    # #dialog --clear --title "$upper_title" --msgbox "Installing Apache/MySQL/PHP/PHPMyAdmin configuration files" 10 30
                    # mv -v /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
                    # cp -v ${dev_directory}etc/httpd.conf /etc/httpd/conf/httpd.conf
                    # cp -v ${dev_directory}etc/httpd-phpmyadmin.conf /etc/httpd/conf/extra/httpd-phpmyadmin.conf
                    # mv -v /etc/php/php.ini /etc/php/php.ini.bak
                    # cp -v ${dev_directory}etc/php.ini /etc/php/php.ini
                
                    # sh -c "echo '#
                    # # /etc/hosts: static lookup table for host names
                    # #

                    # #<ip-address>  <hostname.domain.org>   <hostname>
                    # 127.0.0.1   localhost.localdomain   localhost $HOSTNAME
                    # ::1      localhost.localdomain   localhost
                    # 127.0.0.1 $puser.c0m www.$puser.c0m
                    # 127.0.0.1 $puser.$HOSTNAME.c0m www.$puser.$HOSTNAME.c0m
                    # 127.0.0.1 phpmyadmin.$puser.c0m www.phpmyadmin.$puser.c0m
                    # 127.0.0.1 torrent.$puser.c0m www.torrent.$puser.c0m
                    # 127.0.0.1 admin.$puser.c0m www.admin.$puser.c0m
                    # 127.0.0.1 stats.$puser.c0m www.stats.$puser.c0m
                    # 127.0.0.1 mail.$puser.c0m www.mail.$puser.c0m

                    # # End of file' > /etc/hosts"

                    # sh -c "echo 'NameVirtualHost *:80
                    # NameVirtualHost *:444

                    # #this first virtualhost enables: http://127.0.0.1, or: http://localhost, 
                    # #to still go to /srv/http/*index.html(otherwise it will 404_error).
                    # #the reason for this: once you tell httpd.conf to include extra/httpd-vhosts.conf, 
                    # #ALL vhosts are handled in httpd-vhosts.conf(including the default one),
                    # # E.G. the default virtualhost in httpd.conf is not used and must be included here, 
                    # #otherwise, only domainname1.dom & domainname2.dom will be accessible
                    # #from your web browser and NOT http://127.0.0.1, or: http://localhost, etc.
                    # #

                    # <VirtualHost *:80>
                    # DocumentRoot \"/srv/http/root\"
                    # ServerAdmin root@localhost
                    # #ErrorLog \"/var/log/httpd/127.0.0.1-error_log\"
                    # #CustomLog \"/var/log/httpd/127.0.0.1-access_log\" common
                    # <Directory /srv/http/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # DocumentRoot \"/srv/http/root\"
                    # ServerAdmin root@localhost
                    # #ErrorLog \"/var/log/httpd/127.0.0.1-error_log\"
                    # #CustomLog \"/var/log/httpd/127.0.0.1-access_log\" common
                    # <Directory /srv/http/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/$puser.c0m/public_html\"
                    # ServerName $puser.c0m
                    # ServerAlias $puser.c0m www.$puser.c0m
                    # <Directory /srv/http/$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/$puser.c0m/public_html\"
                    # ServerName $puser.c0m
                    # ServerAlias $puser.c0m www.$puser.c0m
                    # <Directory /srv/http/$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/$puser.$HOSTNAME.c0m/public_html\"
                    # ServerName $puser.$HOSTNAME.c0m
                    # ServerAlias $puser.$HOSTNAME.c0m www.$puser.$HOSTNAME.c0m
                    # <Directory /srv/http/$puser.$HOSTNAME.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/$puser.$HOSTNAME.c0m/public_html\"
                    # ServerName $puser.$HOSTNAME.c0m
                    # ServerAlias $puser.$HOSTNAME.c0m www.$puser.$HOSTNAME.c0m
                    # <Directory /srv/http/$puser.$HOSTNAME.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/usr/share/webapps/phpMyAdmin\"
                    # ServerName phpmyadmin.$puser.c0m
                    # ServerAlias phpmyadmin.$puser.c0m www.phpmyadmin.$puser.c0m
                    # <Directory /usr/share/webapps/phpMyAdmin/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/usr/share/webapps/phpMyAdmin\"
                    # ServerName phpmyadmin.$puser.c0m
                    # ServerAlias phpmyadmin.$puser.c0m www.phpmyadmin.$puser.c0m
                    # <Directory /usr/share/webapps/phpMyAdmin/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/torrent.$puser.c0m/public_html\"
                    # ServerName torrent.$puser.c0m
                    # ServerAlias torrent.$puser.c0m www.torrent.$puser.c0m
                    # <Directory /srv/http/torrent.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/torrent.$puser.c0m/public_html\"
                    # ServerName torrent.$puser.c0m
                    # ServerAlias torrent.$puser.c0m www.torrent.$puser.c0m
                    # <Directory /srv/http/torrent.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/admin.$puser.c0m/public_html\"
                    # ServerName admin.$puser.c0m
                    # ServerAlias admin.$puser.c0m www.admin.$puser.c0m
                    # <Directory /srv/http/admin.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/admin.$puser.c0m/public_html\"
                    # ServerName admin.$puser.c0m
                    # ServerAlias admin.$puser.c0m www.admin.$puser.c0m
                    # <Directory /srv/http/admin.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/stats.$puser.c0m/public_html\"
                    # ServerName stats.$puser.c0m
                    # ServerAlias stats.$puser.c0m www.stats.$puser.c0m
                    # <Directory /srv/http/stats.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/stats.$puser.c0m/public_html\"
                    # ServerName stats.$puser.c0m
                    # ServerAlias stats.$puser.c0m www.stats.$puser.c0m
                    # <Directory /srv/http/stats.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:80>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/mail.$puser.c0m/public_html\"
                    # ServerName mail.$puser.c0m
                    # ServerAlias mail.$puser.c0m www.mail.$puser.c0m
                    # <Directory /srv/http/mail.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>

                    # <VirtualHost *:444>
                    # ServerAdmin $puser@$HOSTNAME
                    # DocumentRoot \"/srv/http/mail.$puser.c0m/public_html\"
                    # ServerName mail.$puser.c0m
                    # ServerAlias mail.$puser.c0m www.mail.$puser.c0m
                    # <Directory /srv/http/mail.$puser.c0m/public_html/>
                    # DirectoryIndex index.htm index.html
                    # AddHandler cgi-script .cgi .pl
                    # Options ExecCGI Indexes FollowSymLinks MultiViews +Includes
                    # AllowOverride None
                    # Order allow,deny
                    # allow from all
                    # </Directory>
                    # </VirtualHost>' > /etc/httpd/conf/extra/httpd-vhosts.conf"

                    # echo sh -c "echo '#
                    # # /etc/hosts: static lookup table for host names
                    # #

                    # #<ip-address>  <hostname.domain.org>   <hostname>
                    # 127.0.0.1   localhost.localdomain   localhost $HOSTNAME
                    # ::1      localhost.localdomain   localhost
                    # 127.0.0.1 $puser.c0m www.$puser.c0m
                    # 127.0.0.1 $puser.$HOSTNAME.c0m www.$puser.$HOSTNAME.c0m
                    # 127.0.0.1 phpmyadmin.$puser.c0m www.phpmyadmin.$puser.c0m
                    # 127.0.0.1 torrent.$puser.c0m www.torrent.$puser.c0m
                    # 127.0.0.1 admin.$puser.c0m www.admin.$puser.c0m
                    # 127.0.0.1 stats.$puser.c0m www.stats.$puser.c0m
                    # 127.0.0.1 mail.$puser.c0m www.mail.$puser.c0m

                    # # End of file' > /etc/hosts"

                    # #TODO
                    # # dialog --clear --backtitle "$upper_title" --title "Extra" --msgbox "Creating self-signed certificate" 10 30
                    # cd /etc/httpd/conf
                    # openssl genrsa -des3 -out server.key 1024
                    # openssl req -new -key server.key -out server.csr
                    # cp -v server.key server.key.org
                    # openssl rsa -in server.key.org -out server.key
                    # openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

                    # mkdir -p /srv/http/root/public_html
                    # chmod g+xr-w /srv/http/root
                    # chmod -R g+xr-w /srv/http/root/public_html

                    # mkdir -p /srv/http/$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/$puser.c0m
                    # chmod -R g+xr-w /srv/http/$puser.c0m/public_html

                    # mkdir -p /srv/http/$puser.$HOSTNAME.c0m/public_html
                    # chmod g+xr-w /srv/http/$puser.$HOSTNAME.c0m
                    # chmod -R g+xr-w /srv/http/$puser.$HOSTNAME.c0m/public_html

                    # mkdir -p /srv/http/phpmyadmin.$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/phpmyadmin.$puser.c0m
                    # chmod -R g+xr-w /srv/http/phpmyadmin.$puser.c0m/public_html

                    # mkdir -p /srv/http/torrent.$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/torrent.$puser.c0m
                    # chmod -R g+xr-w /srv/http/torrent.$puser.c0m/public_html

                    # mkdir -p /srv/http/admin.$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/admin.$puser.c0m
                    # chmod -R g+xr-w /srv/http/admin.$puser.c0m/public_html

                    # mkdir -p /srv/http/stats.$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/stats.$puser.c0m
                    # chmod -R g+xr-w /srv/http/stats.$puser.c0m/public_html

                    # mkdir -p /srv/http/mail.$puser.c0m/public_html
                    # chmod g+xr-w /srv/http/mail.$puser.c0m
                    # chmod -R g+xr-w /srv/http/mail.$puser.c0m/public_html

                #     systemctl start httpd
                #     systemctl start mysqld
                #     sleep 1s
                #     dialog --clear --backtitle "$upper_title" --title "mooOS" --msgbox "Ok... starting MySQL and setting a root password for MySQL...." 10 30
                #     rand=$RANDOM
                #     mysqladmin -u root password $puser-$rand
                #     dialog --backtitle "$upper_title" --title "Extra" --msgbox "You're mysql root password is $puser-$rand\nWrite this down before proceeding..." 10 30
                #     dialog --backtitle "$upper_title" --title "Extra" --msgbox "If you want to change/update the above root password (AT A LATER TIME), then you need to use the following command:\n$ mysqladmin -u root -p'$puser-$rand' password newpasswordhere\nFor example, you can set the new password to 123456, enter:\n$ mysqladmin -u root -p'$puser-$rand' password '123456'" 20 40
                #     ln -s /usr/share/webapps/phpMyAdmin /srv/http/phpmyadmin.$puser.c0m
                #     ln -s /srv/http ${my_home}localhost
                #     chown -R $puser /srv/http

                #     dialog --clear --backtitle "$upper_title" --title "Extra" --msgbox "Your LAMP setup is set to be started manually via the Awesome menu->Services-> LAMP On/Off" 10 30

                #     dialog --clear --backtitle "$upper_title" --title "Extra" --msgbox "If you want LAMP to start at boot, run these commands ay any time as root user:\n\nsystemctl enable httpd.service\nsystemctl enable mysqld.service\nsystemctl enable memcached.service" 10 40
                    
                #     dialog --clear --backtitle "$upper_title" --title "Extra" --yesno "Do you want this to be done now? [default=No]?" 10 30
                #     if [ $? = 0 ] ; then
                #         systemctl enable httpd.service
                #         systemctl enable mysqld.service
                #         systemctl enable memcached.service
                #     fi
                   echo "nothing done, placeholder - ask pdq"
                   sleep 3s
               fi
                systemctl daemon-reload
                sed -i "s/moo/$puser/g" /etc/systemd/system/autologin@.service
                sed -i "s/moo/$puser/g" /etc/systemd/system/transmission.service
                chmod -R 777 /run/transmission
                chown -R $puser /run/transmission

                # dialog --clear --backtitle "$upper_title" --title "mooOS" --yesno "Enable automatic login to virtual console?" 10 30
                # if [ $? = 0 ] ; then
                #     systemctl disable getty@tty1
                #     systemctl enable autologin@tty1
                #     systemctl start autologin@tty1
                # fi
                
                # not needed anymore since zsh shell is set via chroot script run previously
                # dialog --clear --backtitle "$upper_title" --title "mooOS" --msgbox "Ok, setup is complete... the next screen will prompt you for your user password..." 10 40
                # chsh -s $(which zsh)

          #       if [ "$archtype" = "x86_64" ]; then
          #       dialog --clear --backtitle "$upper_title" --title "mooOS" --msgbox "exiting install script...\n\nIf complete, type: sudo reboot (you may also want to search, chose and install a video driver now.\n\npacaur XXXX\n\nReplacing XXXX with:\n'lib32-ati-dri: for open source ATI driver users'
          # 'lib32-catalyst-utils: for AMD Catalyst users'
          # 'lib32-intel-dri: for open source Intel driver users'
          # 'lib32-nouveau-dri: for Nouveau users'
          # 'lib32-nvidia-utils-bumblebee: for NVIDIA + Bumblebee users'
          # 'lib32-nvidia-utils: for NVIDIA proprietary blob users'" 30 70
              #  else
                dialog --clear --backtitle "$upper_title" --title "mooOS" --msgbox "exiting install script...\n\nIf complete, type: sudo reboot (you may also want to search, chose and install a video driver now.\n\npacaur XXXX\n\nReplacing XXXX with:\n'ati-dri: for open source ATI driver users'
'catalyst-utils: for AMD Catalyst users'\n
'intel-dri: for open source Intel driver users'\n
'nouveau-dri: for Nouveau users'\n
'nvidia-utils-bumblebee: for NVIDIA + Bumblebee users'\n
'nvidia-utils: for NVIDIA proprietary blob users'" 30 70
               # fi
            #fi
        fi
        current_selection 11
    }

    chroot_menu() {
        #echo "make it so"
        rootpasswd=$(cat $TMP/rootpasswd)
        CUR=$(cat $_CCURRENT)
        dialog \
            --default-item "$CUR" --colors --backtitle "$upper_title" --title "mooOS Installer (chroot)" \
            --menu "Select action:" 20 60 11 \
            1 $clr"Generate hostname [${GEN_HOSTNAME}]" \
            2 $clr"Generate timezone [${GEN_TIMEZONE}]" \
            3 $clr"Generate locale [${GEN_LANG}]" \
            4 $clr"Set root password [$rootpasswd]" \
            5 $clr"Create default user and add to sudoers" \
            6 $clr"Install Bootloader" \
            7 $clr"View/confirm generated data" \
            8 $clr"View/edit files [optional]" \
            9 $clr"Set up Network [mandatory]" \
            10 $clr"Install extras" \
            11 $clr"Return to Installer" 2>$_TEMP

        if [ $? = 1 ] || [ $? = 255 ] ; then
            exiting
            return 0
        fi

        choice=$(cat $_TEMP)
        case $choice in
            1) gen_hostname;;
            2) gen_tz;;
            3) gen_locale;;
            4) set_root_pass;;
            5) add_user;;
            6) install_bootloader;;
            7) conf_view;;
            8) edit_file;;
            9) make_internet;;
            10) make_mooOS;;
            11) exiting;;
        esac
    }

    # utility execution
    while true
    do
        chroot_menu
    done
fi