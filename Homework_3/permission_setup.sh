#!/bin/bash
#this function is use for change owner of file
help(){
	echo "Usage: $0 [-c user [group]] file  : change owner of file to user and group"
	echo "       $0 -p octal file           : change permission of file to octal format"
	echo "       $0                         : interactive mode"
}
changeowner(){
	local us=$1 #paramter 1 is the user for cahgne to owner of file
	local gp=$2 #parameter 3 is group if user input
	local file=$([ $# -gt 2 ] && echo $3 || echo $2) #parameter 2 is store file
	if [ ! -e $file ] ; then
		echo "file or directory : $file is not exists" ; exit 1
	else
		owner=$(stat -c %U $file)
		if [ $us = $owner ] ; then
			echo "the current owner is current user : $us alredy " ; exit 1
		else
			echo -n "to change file owner is required password of superuser " #required password to change owner
			if [ $gp != "." ] ; then
				# grouponwer=$(stat -c %G $file)
				# if [ $gp = $grouponwer ] ; then
				# 	echo "the current group owner is current group : $gp alredy " ; exit 1
				# fi
				if su -c "chown $us:$gp $file" root ; then
					echo "Change file owner to user: $us and group: $gp is succes"
				else 
					echo "can not change owner please check user or group is exists" ; exit 1
				fi
			else
				su -c "chown $us $file" root
				echo "Change file owner to current user: $us is succes"
			fi
		fi
	fi
}
changepermission(){
	local octal=$1
	local file=$2
	if [ ! -e $file ] ; then
		echo "file or direcotry : $file is not exists" ; exit 1
	fi
	if ! chmod $octal $file 2>> /dev/null ; then
		echo -n "to change permission this file is required superuser's "
		su -c "chmod $octal $file" root
	fi
	if [ -d $file ] ; then
		echo "$(ls -l $file/..)"
	else
		echo "$(ls -l $file)"
	fi
}
if [ $# -gt 0 ] ; then
	while getopts ":c:p:" opt
	do
		case $opt in
			c) c_opt=true;;
			p) p_opt=true;echo "$OPTARG";;
			:) echo "-$OPTARG is require value " ; exit 1;;
			*) echo "your option -$OPTARG is invalid " ; help; exit 1;;
		esac
	done
	if [ $c_opt ] ; then
			shift 1
			user=$( [ $# -gt 2 ] && echo $1 || echo $USER )
			group=$( [ $# -eq 3 ] && echo $2 || echo "." )
			file=$( [ $# -eq 1 ] && echo $1 || [ $group != "." ] && echo $3 || echo $2 )
			echo "$user : $group : $file"
			changeowner $user $group $file
	fi
	if [ $p_opt ] ; then
			if [ $# -ne 3 ] ; then
				echo "option -p require two value " ; exit 1
			fi
			if [ ! -e $3 ] ; then
                echo "file or direcotry : $2 is not exists" ; exit 1
			fi
				changepermission $2 $3
	fi
else
	while true ; do
		clear
		echo "====Permission Setup Menu===="
		echo "1. Change Owner of File/Directory"
		echo "2. Change Permission of File/Directory"
		echo "3. Exit"
		echo -n "Please enter your choice : "
		read choice
		if [ $((choice)) -lt 3 ] ; then
			echo -n "display list directory [default is current directory] or n for not display: "
			read dir
			[ "$dir" = "n" ] ||
			echo "$(ls -l $([ -z $dir ] && echo "." || echo $dir) )"
		fi
		case $choice in
			1) echo "============change Owner of File/Directory============"
			   echo -n "Enter file/directory name with path : "
			   read filename
			   echo -n "Enter new owner user name : "
			   read newuser
			   echo -n "Enter new group name default no change : "
			   read newgroup
			   newgroup=$( [ -z $newgroup ] && echo "." || echo $newgroup )
			   changeowner $newuser $newgroup $filename;;
			2) echo "============change Permission of File/Directory============"
			   echo -n "Enter file/directory name with path : "
			   read filename
			   echo -n "Enter permission in octal format : "
			   read octal
			   changepermission $octal $filename;;
			3) clear; exit 0 ;;
			*) echo "Your choice is invalid";;
		esac
		echo -n "Press any key to refresh or 'q' to quit..."
		read -n 1 input
		if [ "$input" = "q" ] || [ "$input" = "Q" ] ; then
			break
		fi
	done
fi
##################################################################################################