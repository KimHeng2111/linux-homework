#!/bin/bash
echo "$EUI"
cur_user=$USER
group="users"
if [ "$EUID" -ne 0 ] ; then
	echo "Please run with super user$USER"
else
	echo "wow are you super user $USER"
fi
if ! test -e "/home/linux_lab" ; then
	echo "create /home/linux_lab directory"
	$(sudo mkdir "/home/linux_lab")
	$(sudo chown $cur_user:$group "/home/linux_lab") 	
else
	echo "continu"
fi
