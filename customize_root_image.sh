#!/bin/bash
## mooOS
set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/.zshrc.root /root/.zshrc

if [ ! -d /home/moo ]; then
	rsync -av /etc/skel/ /home/moo --exclude=.zshrc.root
	ln -s /home/moo/.local/applications/install_mooOS.desktop /home/moo/Desktop/install_mooOS.desktop
	chown moo -R /home/moo
	chmod -R g+r,o+r /home/moo
	chgrp -R users /home/moo
fi

#ln -s /usr/lib/systemd/system/lxdm.service display-manager.service

su -c "echo 'moo ALL=(ALL) NOPASSWD: ALL' >>  /etc/sudoers"

useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /usr/bin/zsh arch

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

#chmod -R 777 /run/transmission
#chown -R moo /run/transmission

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
