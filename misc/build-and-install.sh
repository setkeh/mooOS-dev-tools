#!/bin/bash
#Todo
# * add workaround for qt4-ubuntu
# * add error detection
# * check for root if installing

ARCH_SUPPORTED=('i686' 'x86_64')
ARCH=""

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
			echo "-s [package-name] start at package"
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
		s)
			NOSTART=true
			STARTPKG=$OPTARG
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

if [ "${ARCH}" == "i686" ]; then
	MAKEPKG="schroot -p --"
else
	MAKEPKG="makepkg"
fi

packages=($(./What_can_I_update\?.py -l | grep -v qt4-ubuntu))
for package in "${packages[@]}"; do
	if [ "$NOSTART" == "true" ]; then
		if [ "${package}" != "$STARTPKG" ]; then
			continue
		else
			NOSTART=false
		fi

	fi

	if [[ "$IGNOREPACKAGE" != "" && "$IGNOREPACKAGE" == "${package}" ]]; then
		continue
	fi
	if [[ "$INSTALLPACKAGE" != "" && "$INSTALLPACKAGE" != "${package}" ]]; then
		continue
	fi

	## branding etc
	if [ "${package}" == "lightdm-ubuntu" ]; then
		cp -rv ~/github/mooOS-dev-tools/lightdm-ubuntu/* ${package}/
	elif [ "${package}" == "lightdm-unity-greeter" ]; then
		cp -rv ~/github/mooOS-dev-tools/lightdm-unity-greeter/* ${package}/
	elif [ "${package}" == "unity" ]; then
		cp -rv ~/github/mooOS-dev-tools/unity/* ${package}/
	elif [ "${package}" == "unity-asset-pool" ]; then
		cp -rv ~/github/mooOS-dev-tools/unity-asset-pool/* ${package}/
	fi

	cd "${package}"
	rm -rf src

	if [ "$NOCONFIRM" == "true" ];then
		$MAKEPKG --nocheck -fsic --noconfirm
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
