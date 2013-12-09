#!/bin/bash
## mooOS
sleep 5s
set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime


## figure out architecture type
archtype="$(uname -m)"
if [ "$archtype" = "x86_64" ]; then
	rm /etc/pacman.conf /etc/pacman-i686.conf
	mv /etc/pacman-x86_64.conf /etc/pacman.conf
fi

sed -i "s/http:\/\/repo.mooOS.pdq/http:\/\/repos.mooos.org/g" /etc/pacman.conf
sed -i "s/CacheDir/#CacheDir/g" /etc/pacman_conf

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/.zshrc.root /root/.zshrc

# fix missing icons in .desktop files
sed -i "s/Icon=mediadownloader/Icon=mplayer/g" /usr/share/applications/mediadownloader.desktop
#sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukbackup.desktop
#sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukcleaner.desktop
#sed -i "s/Icon=nepomukpreferences-desktop/Icon=preferences-desktop/g" /usr/share/applications/kde4/nepomukcontroller.desktop
sed -i "s/Exec=/Exec=kdesudo /g" /usr/share/applications/gparted.desktop
sed -i "s/Icon=preferences-desktop-display-randr/Icon=preferences-desktop-display/g" /usr/share/applications/kde4/krandrtray.desktop
sed -i "s/Icon=hwinfo/Icon=preferences-system/g" /usr/share/applications/kde4/kinfocenter.desktop
sed -i "s/Icon=\/opt\/johnny\/johnny-128.png/Icon=seahorse/g" /usr/share/applications/johnny.desktop

if [ -f /usr/share/applications/kde4/nepomukcleaner.desktop ]; then
	rm /usr/share/applications/kde4/nepomukcleaner.desktop
fi

if [ -f /usr/share/applications/kde4/akonaditray.desktop ]; then
	rm /usr/share/applications/kde4/akonaditray.desktop
fi

if [ -f /usr/share/applications/kde4/nepomukbackup.desktop ]; then
	rm /usr/share/applications/kde4/nepomukbackup.desktop
fi

if [ -f /usr/share/applications/feh.desktop ]; then
	rm /usr/share/applications/feh.desktop
fi

if [ -f /usr/share/applications/kde4/klipper.desktop ]; then
	rm /usr/share/applications/kde4/klipper.desktop
fi

if [ -f /usr/share/applications/kde4/nepomukcontroller.desktop ]; then
	rm /usr/share/applications/kde4/nepomukcontroller.desktop
fi

if [ -f /usr/share/applications/enlightenment_filemanager.desktop ]; then
	rm /usr/share/applications/enlightenment_filemanager.desktop
fi

if [ -f /usr/share/applications/avahi-discover.desktop ]; then
	rm /usr/share/applications/avahi-discover.desktop
fi

if [ -f /usr/share/applications/bssh.desktop ]; then
	rm /usr/share/applications/bssh.desktop
fi

if [ -f /usr/share/applications/bvnc.desktop ]; then
	rm /usr/share/applications/bvnc.desktop
fi

if [ -f /usr/share/enlightenment/data/themes/Post_It_White.edj ]; then
	rm -f /usr/share/enlightenment/data/themes/Post_It_White.edj
fi

if [ -f /usr/share/enlightenment/data/themes/Simply_White_etk.edj ]; then
	rm -f /usr/share/enlightenment/data/themes/Simply_White_etk.edj
fi

if [ -f /usr/share/enlightenment/data/themes/New_Millenium.edj ]; then
	rm -f /usr/share/enlightenment/data/themes/New_Millenium.edj
fi

if [ -f /usr/share/enlightenment/data/themes/qv4l2.desktop ]; then
	rm -f /usr/share/enlightenment/data/themes/qv4l2.desktop
fi

if [ ! -d /home/moo ]; then
	rsync -avp /etc/skel/ /home/moo --exclude=.zshrc.root
	ln -sf /home/moo/.local/applications/install_mooOS.desktop /home/moo/install_mooOS.desktop
	chmod +x /home/moo/install_mooOS.desktop
	chmod +x /home/moo/Github/mooOS-dev-tools/installer/chroot-install.sh
	chmod +x /home/moo/Github/mooOS-dev-tools/installer/installer.sh
	#su -l moo -c 'kbuildsycoca4 --noincremental'
	#chmod -R g+r,o+r /home/moo
	chgrp -R users /home/moo
	chown moo:users -R /home/moo
	#chgrp -R users /tmp/moo-firefox-qrtww0pl.Default-User
	#chown moo -R /tmp/moo-firefox-qrtww0pl.Default-User
fi

#ln -s /usr/lib/systemd/system/lxdm.service display-manager.service

su -c "echo 'moo ALL=(ALL) NOPASSWD: ALL' >>  /etc/sudoers"

#useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch

pacman -Syu --noconfirm
pacman -Rs sublime-text-dev --noconfirm

su -l moo -c "pacaur -S sublime-text-dev --noconfirm --noedit" #

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
squid -z &

#chmod -R 777 /run/transmission
#chown -R moo /run/transmission
systemctl disable iptables.service cpupower.service
systemctl enable multi-user.target pacman-init.service choose-mirror.service
systemctl enable ntpd.service
systemctl enable tor.service
systemctl enable privoxy.service
systemctl enable preload.service
systemctl enable polipo.service
systemctl enable cronie.service
#systemctl daemon-reload
#systemctl disable getty@tty1
#systemctl enable autologin@tty1

exit 0