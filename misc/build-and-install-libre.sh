#!/bin/bash
#Todo
# * add workaround for qt4-ubuntu
# * add error detection
# * check for root if installing

ARCH_SUPPORTED=('i686' 'x86_64')
ARCH=""
LIBRES="audio-convert-libre avidemux-libre cdrkit-libre cups-filters-libre kdelibs-libre mcomix-libre mesa-demos-libre mplayer-libre openexr-libre rp-pppoe-libre sdl-libre spectrwm-libre unzip-libre unar mozilla-searchplugins cpupower-libre p7zip-libre xbmc-libre mc-libre kdeutils-ark-libre iceweasel-libre kdebase-runtime-libre ghostscript-libre texlive-bin-libre"
PRISMS="bitlbee-libre-nonprism evolution-data-server-nonprism gnome-online-accounts-nonprism"
MOO="geeh moo-scripts moo-tools moo-wallpapers moo-zsh"
UBU="bamf compiz-ubuntu dee-qt dee-ubuntu evemu frame gnome-control-center-ubuntu gnome-settings-daemon-ubuntu gsettings-qt hud ido indicator-application indicator-appmenu indicator-bluetooth indicator-cpufreq indicator-datetime indicator-keyboard indicator-messages indicator-power indicator-printers indicator-remindor indicator-session indicator-sound libappindicator libappindicator3 libcolumbus libdbusmenu-glib libdbusmenu-gtk2 libdbusmenu-gtk3 libdbusmenu-qt5 libindicate libindicate-gtk2 libindicate-gtk3 libindicate-qt libindicator libindicator3 libnautilus-extension-ubuntu liboverlay-scrollbar liboverlay-scrollbar3 libtimezonemap libunity libunity-misc lightdm-ubuntu lightdm-unity-greeter metacity-ubuntu nautilus-ubuntu numix-themes nux overlay-scrollbar properties-cpp python2-pyside python2-shiboken remindor-common remindor-qt sni-qt ubuntu-sounds unity unity-asset-pool unity-control-center unity-gtk-module unity-language-packs unity-lens-applications unity-lens-files unity-lens-music unity-lens-photos unity-lens-video unity-scope-home unity-scopes unity-tweak-tool xpathselect"
PATCHED="gst-plugins-bad-libre gstreamer0.10-bad-libre"

while getopts ednhbp:ais: opt; do
	case $opt in
		n)
			NOCONFIRM=true
			;;
		h)
			echo "arguments:"
			echo "-h Shows this help file"
			echo "-a Architecture to build for"
			echo "-n installs package without user confirmation"
			echo "-b just builds without installing"
			echo "-p [package-name] only build specific package"
			echo "-i [package-name] ignore certain package"
			echo "-d only download required sources (do not build or install)"
			echo "-e stop on error "
			exit
			;;
		e)
			set -e
			echo "WARNING: Stopping on errors"
			;;
		a)
			ARCH=$OPTARG
			;;
		b)
			NOINSTALL=true
			;;
		p)
			INSTALLPACKAGE=$OPTARG
			;;
		i)
			IGNOREPACKAGE=$OPTARG
			;;
		d)	DOWNLOAD=true
	esac
done

#check for conflicting arguments
if [ "$NOINSTALL" == true ]; then
	if [ "$NOCONFIRM" == true ]; then
		echo "Conflicting arguments...exiting"
		exit
	fi
fi

if [ -z "${ARCH}" ]; then
	ARCH=$(uname -m)
fi

# Make sure architecture is supported
SUPPORTED=false
for i in ${ARCH_SUPPORTED[@]}; do
	if [ "x${i}" == "x${ARCH}" ]; then
		SUPPORTED=true
		break
	fi
done
if [ "x${SUPPORTED}" != "xtrue" ]; then
	echo "Unsupported architecture ${ARCH}!"
exit 1
fi

#MAKEPKG="makepkg"

MAKEPKG="schroot -p -- makepkg"

	if [[ "$IGNOREPACKAGE" != "" && "$IGNOREPACKAGE" == "${package}" ]]; then
		continue
	fi
	if [[ "$INSTALLPACKAGE" != "" && "$INSTALLPACKAGE" != "${package}" ]]; then
		continue
	fi

cd libre/
for package in $LIBRES
do 
	cd "${package}"
	rm -rf src
	if [ "$NOCONFIRM" == "true" ];then
		## i686
		$MAKEPKG --nocheck -sfc --noconfirm
		## x86_64
		#$MAKEPKG --nocheck -sfic --noconfirm
	elif [ "$NOINSTALL" == "true" ]; then
		$MAKEPKG --nocheck -fc
	elif [ "$DOWNLOAD" == "true" ]; then
		echo "Downloading ${package}..."
		$MAKEPKG -g &> /dev/null
	else
		$MAKEPKG --nocheck -fsic
	fi
	cd ..
done
cd ..

cd nonprism/
for package in $PRISMS
do 
	cd "${package}"
	rm -rf src
	if [ "$NOCONFIRM" == "true" ];then
		## i686
		$MAKEPKG --nocheck -sfc --noconfirm
		## x86_64
		#$MAKEPKG --nocheck -sfic --noconfirm
	elif [ "$NOINSTALL" == "true" ]; then
		$MAKEPKG --nocheck -fc
	elif [ "$DOWNLOAD" == "true" ]; then
		echo "Downloading ${package}..."
		$MAKEPKG -g &> /dev/null
	else
		$MAKEPKG --nocheck -fsic
	fi
	cd ..
done
cd ..

exit 0
