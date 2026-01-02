#!/bin/bash
#function check user or group already exists or not
check(){
	opt=$1
	name=$2
	if [ $opt = "-u" ] ; then
		if [[ $(cat "/etc/passwd" | grep "^$name") ]] ; then
			echo true;
		fi
	elif [ $opt = "-g" ] ; then
		if [[ $(cat "/etc/group" | grep "^$name") ]] ; then
			echo true;
		fi
	fi
}
#function for create group
creategroup(){
	local gname=$( [ $2 ]  && echo $2 || echo $1 )
	echo "Group name: $gname"
	local user=$([ $# -eq 2 ] && echo $1 || echo "")
	if [ $(check -g $gname) ] ; then
		echo "your group is already exists"; exit 1	
	else
		if [[ $(groups $USER) == *"sudo "* ]] ; then
			sudo groupadd $([ $user ] && echo "-U $user") $gname
			echo "$(cat "/etc/group" | grep "^$gname")"
		else
			echo -n "required superuser " 
			su -c "groupadd $([ $user ] && echo "-U $user") $gname" root
			echo "$(cat "/etc/group" | grep "^$gname")"
		fi
	fi
}
#function for create user
createuser(){
	local homedir=$([ $# -ge 2 ] && echo "$1" || echo "")
	local group=$([ $# -ge 3 ] && echo "$2" || echo "")
	local uname=$([ $# -eq 3 ] && echo "$3" || ([ $# -eq 2 ] && echo "$2" || echo "$1"))
	echo "Username: $uname"
	echo "Home Directory: $([ $homedir = "y" ] && echo "Create" || echo "Not Create")"
	echo "Group: $([ $group ] && echo "$group" || echo "None")"
	if [[ $(check -u $uname) ]]  ; then
		echo "your username is already exists"; exit 1
	else
		if [[ $(groups $USER) == *"sudo "* ]] ; then
			sudo adduser $([[ $homedir == "n" ]] && echo "--no-create-home") --disabled-password --gecos "" "$uname"
			$([ $group ] && echo "sudo usermod -aG $group $uname")
			sudo passwd -de $uname > /dev/null
		else
			echo -n "required superuser password : "
			read -s password
			echo ""
			home=$([ $homedir = "n" ] && echo "--no-create-home")
			su -c "adduser $home --disabled-password --gecos '' $uname" root <<< "$password" >/dev/null 2>&1
			if [ $group ] ; then
				su -c "usermod -aG $group $uname" root <<< "$password" > /dev/null 2>&1
			fi
			su -c "passwd -de $uname" root <<< "$password" > /dev/null	2>&1
		fi
		echo "create user $uname success"
		echo "$(cat "/etc/passwd" | grep "^$uname")"
	fi
}
userstogroup(){
	local user=$1
	local group=$2
	if [[ $(check -g $group) ]] ; then
		IFS="," read -ra users <<< "$user"
		for u in "${users[@]}"; do
			if ! [[ $(check -u $u) ]] ; then
				echo "user $u is not exists " ; exit 1
			else
				if [[ $(groups $USER) == *"sudo "* ]] ; then
					sudo usermod -aG $group $u  
				else
					echo -n "required superuser "
					su -c "usermod -aG $group $u" root
				fi
				echo "$(cat "/etc/group" | grep "^$group")"
			fi
		done
	else
		echo "your group or user you want to add is invalid !!"
	fi
}
########################################################################
#################main code###########################################
if [ $# -eq 0 ] ; then
	while true ; do
		clear
		echo "====User Management Menu===="
		echo "1. Create Group"
		echo "2. Create User"
		echo "3. Add Users to Group"
		echo "4. Exit"
		echo -n "Your choice [1-4]: "
		read choice
		case $choice in
			1) echo -n "Enter group name: "
			   read gname
			   echo -n "Enter username to join in group(leave blank if none): "
			   read user
			   creategroup $user $gname
			   read -p "Press [any key] key to continue..." ;;
			2) echo -n "Enter username: "
			   read uname
			   echo -n "create home directory (y/n)? default n: "
			   read homedir
			   homedir=$( [ "$homedir" = "y" ] && echo "y" || echo "n" )
			   echo -n "Enter exists group or blank : "
			   read group
			   echo "$uname : $homedir : $group"
			   createuser $homedir $group $uname
			   read -p "Press [any key] key to continue..." ;;
			3) echo -n "Enter username(s) (comma separated for multiple): "
			   read users
			   echo -n "Enter group name: "
			   read gname
			   userstogroup $users $gname
			   read -p "Press [any key] key to continue..." ;;
			4) exit 0 ;;
			*) echo "Invalid choice!" ; read -p "Press [any key] key to continue..." ;;
		esac
	done
else
	while getopts ":ug:hA:" opt ; do
		case $opt in 
			u) u=true;;
			g) g=true; gname=$OPTARG;;
			h) h=true;;
			A) A=true;;
			:) echo "required value of option -$OPTARG";;	
			\?) echo "option -$OPTARG is invalid";;
		esac
	done
	if [ $u ] ; then
		shift $(($OPTIND -1 ))
		if [ $# -eq 0 ] ; then
			echo "you missing username for create user!!!";exit 2
		else
			uname=$1
		fi
		createuser $([ $h ] && echo "y" || echo "n") $([ $g ] && echo "$gname") $uname
	elif [ $g ] ; then
		creategroup $gname
	elif [ $A ] ; then
		if [ $# -eq 0 ] ; then
			echo "you missing username for add group!!!";exit 2
		else
			shift 1
			user=$([ $# -gt 1 ] && echo $1 || echo $USER )
			group=$([ $# -eq 2 ] && echo $2 || echo $1)
			userstogroup $user $group
		fi
	fi
fi

########################################################################
