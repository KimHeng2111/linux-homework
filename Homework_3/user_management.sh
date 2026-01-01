#!/bin/bash
g="" #option for create group
u="" #option for create user
h="" #option for home directory for now account
A="" #option for add group to user

#function check user or group already exists or not
check(){
	opt=$1
	name=$2
	if [ $opt = "-u" ] ; then
		if [ $(cat "/etc/passwd" | grep "^$name") ] ; then
			echo true;
		fi
	elif [ $opt = "-g" ] ; then
		if [ $(cat "/etc/group" | grep "^$name") ] ; then
			echo true;
		fi
	fi
}
#function for create group

while getopts ":g:u:h:A:" opt ; do
	case $opt in 
		g) g=true; gname=$OPTARG;;
		u) u=true; uname=$OPTARG;;
		h) h=true; homedir=$OPTARG;;
		A) A=true; group=$OPTARG;;
		:) echo "required value of option -$OPTARG";;	
		\?) echo "option -$OPTARG is invalid";;
	esac
done
if [ $A ] ; then
	shift $(($OPTIND -1 )) 
	if [ $# -eq 0 ] ; then
		echo "you missing username for add group!!!";exit 2
	else
		user=$1
		if [[ $(check -g $group)  &&  $(checkuser -u $user) ]] ; then
			usermod -AG $group $user  
			echo "$(groups $user)"
		else
			echo "your group or user you want to add is invalid !!"
		fi
	fi
else
	if [ $g ] ; then
		if [ $(check -g $gname) ] ; then
			echo "your group is already exists"; exit 1	
		else
			if [[ $(groups $USER) == *"sudo "* ]] ; then
				sudo groupadd $gname
				echo "$(cat "/etc/group" | grep "^$gname")"
			else
				echo -n "required superuser " 
				su -c "groupadd $gname" root
				echo "$(cat "/etc/group" | grep "^$gname")"
			fi
			#sudo groupadd $gname
			#echo "$(cat "/etc/group" | grep "^$gname")"
		fi
	elif [ $u ] ; then
		if [ $(check -u $uname) ] ; then
			echo "your username is already exists"; exit 1
		else
			if [[ $(groups $USER) == *"sudo "* ]] ; then
                        	sudo useradd
			else
                                echo -n "required superuser "
                                su -c "groupadd $gname" root
                                echo "$(cat "/etc/group" | grep "^$gname")"
                        fi
	fi

fi	
			

