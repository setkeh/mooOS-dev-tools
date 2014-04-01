#!/usr/bin/bash
## moo

sleep 5s
set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
ln -sf /usr/bin/meld /usr/bin/vimdiff
#chown -Rv moo:users /usr/share/doc/qt/examples/   

## figure out architecture type
archtype="$(uname -m)"

if [ "$archtype" = "x86_64" ]; then
	rm /etc/pacman.conf /etc/pacman-i686.conf
	mv /etc/pacman-x86_64.conf /etc/pacman.conf
else
	rm /etc/pacman-i686.conf /etc/pacman-x86_64.conf
fi

## change moo repo from local to remote 
sed -i "s/http:\/\/repo.mooOS.pdq/http:\/\/repos.mooos.org/g" /etc/pacman.conf
sed -i "s/CacheDir/#CacheDir/g" /etc/pacman.conf

## do some root specific stuffs
usermod -s /usr/bin/zsh root
cp -aT /etc/skel/.zshrc.root /root/.zshrc

# fix missing icons in .desktop files
if [ -f /usr/share/applications/mediadownloader.desktop ]; then
	sed -i "s/Icon=mediadownloader/Icon=mplayer/g" /usr/share/applications/mediadownloader.desktop
fi
if [ -f /usr/share/applications/gparted.desktop ]; then
	sed -i "s/Exec=/Exec=kdesudo /g" /usr/share/applications/gparted.desktop
fi
if [ -f /usr/share/applications/kde4/krandrtray.desktop ]; then
	sed -i "s/Icon=preferences-desktop-display-randr/Icon=preferences-desktop-display/g" /usr/share/applications/kde4/krandrtray.desktop
fi
if [ -f /usr/share/applications/kde4/kinfocenter.desktop ]; then
	sed -i "s/Icon=hwinfo/Icon=preferences-system/g" /usr/share/applications/kde4/kinfocenter.desktop
fi
if [ -f /usr/share/applications/johnny.desktop ]; then
	sed -i "s/Icon=\/opt\/johnny\/johnny-128.png/Icon=seahorse/g" /usr/share/applications/johnny.desktop
fi

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

## create live home
if [ ! -d /home/moo ]; then
	rsync -avp /etc/skel/ /home/moo --exclude=.zshrc.root
	chgrp -R users /home/moo
	chown moo:users -R /home/moo
fi

#ln -s /usr/lib/systemd/system/lxdm.service display-manager.service
#useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch

## suod/su perm stuffs
su -c "echo 'moo ALL=(ALL) NOPASSWD: ALL' >>  /etc/sudoers"
chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel

## create fresh full mirrorlist
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf

## create the required squid cache directories
squid -z &

## systemd stuffs
systemctl disable iptables.service cpupower.service
systemctl enable multi-user.target pacman-init.service choose-mirror.service
systemctl enable ntpd.service
systemctl enable tor.service
systemctl enable privoxy.service
systemctl enable preload.service
systemctl enable polipo.service
systemctl enable cronie.service
systemctl enable lightdm.service

exit 0