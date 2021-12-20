#!/bin/bash
# Looking Glass Helper
# For Gentoo (Systemd)
# NOTE: Systemd version is untested but it should work!!

# Helper by @pavolelsig on GitHub
# Gentoo helper by @speediegamer on GitHub

# Making sure that the looking glass tar.gz or folder is present
# Yeah I added automatic tar.gz extraction because it's something I wanted to add!

test -f *.tar.gz && tar xpvf *.tar.gz

if ! [ -d looking*/client ]
then
echo "Please copy the Looking Glass folder or tar.gz into this folder/directory!!"
exit
fi


# Making sure this script runs with elevated privileges
if [ $(id -u) -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi



# Better (imo) way to check if the machine is running Gentoo
# Wouldn't be possible with other distros but since Gentoo is
# the only distro with a make.conf this should do.

# I guess it also allows you to use it on Gentoo based distros, too?

if [ -f "/etc/portage/make.conf" ]; then
    emerge --noreplace --verbose sys-devel/binutils dev-util/cmake media-fonts/freefonts media-libs/libsdl2 media-libs/sdl2-ttf app-emulation/spice-protocol media-libs/fontconfig dev-libs/nettle
else 
    echo "This script does not support your current distribution. Only Gentoo (and possibly gentoo based distros) are supported!"
    echo "You can still install Looking Glass manually!"
    exit
fi

VIRT_USER=`logname`

# Identifying user to set permissions

echo 
echo "User: $VIRT_USER will be using Looking Glass on this PC. "
echo "If that's correct, press (y) otherwise press (n) and you will be able to specify the user."
echo 
echo "y/n?"
read USER_YN


# Allowing the user to manually edit the Looking Glass user
if [ $USER_YN = 'n' ] || [ $USER_YN = 'N' ]
	then
USER_YN='n'
		while [ '$USER_YN' = "n" ]; do
			echo "Enter the new username: "
			read VIRT_USER


			echo "Is $VIRT_USER correct (y/n)?"
			read USER_YN
		done
fi

echo User $VIRT_USER selected. Press any key to continue:
read ANY_KEY

# Looking Glass requirements: /dev/shm/looking_glass needs to be created on startup
echo "touch /dev/shm/looking-glass && chown $VIRT_USER:kvm /dev/shm/looking-glass && chmod 660 /dev/shm/looking-glass" > lg_start.sh

# Create a Systemd service to initialize the GPU on startup

cp lg-service-systemd.service /etc/systemd/system/lg-service-systemd.service
chmod 644 /etc/systemd/system/lg-service-systemd.service

mv lg_start.sh /usr/bin/lg_start.sh

chmod +x /usr/bin/lg_start.sh
chmod +x /etc/systemd/system/lg-service-systemd.service

systemctl enable lg-service-systemd.service
systemctl start lg-service-systemd.service

# Compiling Looking Glass

if [ -a looking*.tar.gz ]
then 
mv looking*.tar.gz tar_lg.tar.gz
fi

cd looking*
mkdir client/build
cd client/build
cmake ../
make
chown $VIRT_USER looking-glass-client

exit
