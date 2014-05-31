mooOS installer
===============

Installer for mooOS using dialog.

Depends on: dialog rsync arch-install-scripts update-mirrorlist efl gtk3 hicolor-icon-theme desktop-file-utils

Install with
------------

    $ makepkg -sfi PKGBUILD

example:

     $ rm -r ~/abs/moo && mkdir -p ~/abs/moo && cd ~/abs/moo && wget https://raw.github.com/idk/mooOS-dev-tools/master/installer/moo-tools.install && wget https://raw.github.com/idk/mooOS-dev-tools/master/installer/PKGBUILD && makepkg -sfi

Remove with
-----------

    # pacman -Rs moo-tools

Run with
--------

In Terminal run:

	# moo_installer

With enlightenment everything starter <Alt>+<Esc>:

	mooOS installer


SUPPORT
-------

[The Linux Distro Community][1]

[pdq][2]


HISTORY
-------
* 2013-11-16: Version 0.2.2

Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_foo_bar`)
3. Commit your changes (`git commit -am "Added foo and bar"`)
4. Push to the branch (`git push origin my_foo_bar`)
5. Create an [Issue][2] with a link to your branch
6. Join the Linux Distro Community IRC! :D

SHARE AND ENJOY!
----------------

[1]: http://www.linuxdistrocommunity.com
[2]: https://github.com/idk/gtmsu_servicemenu/issues
[3]: http://tmsu.org
