#!/bin/bash
#current user
user=$(getent passwd $UID | cut -d: -f1)
#this function is use for change owner of file
changeowner(){
	local us=$1 #paramter 1 is the user for cahgne to owner of file
	local file=$2 #parameter 2 is store file
	echo -n "to change file owner is required password of superuser " #required password to change owner
	su -c "chown $us $file" root
	echo "Change file owner to current user: $us is succes"
}
changepermission(){
	local octal=$1
	local file=$2
	if ! chmod $octal $file 2>> /dev/null ; then
		echo -n "to change permission this file is required password of superuser "
		su -c "chmod $octal $file" root
	fi
	if [ -d $file ] ; then
		echo "$(ls -l $file/..)"
	else
		echo "$(ls -l $file)"
	fi
}

if [ $# -le 1 ] ; then
	if [ $# -eq 0 ] ; then
		dir="."
	else
		if [ ! -e $1 ] ; then
                        echo "file or direcotry : $1 is not exists" ; exit 2
                else
                         dir=$1
                fi
	fi
	ls -l $dir
else
	if [ $1 = "-c" ] ; then
		if [ $# -eq 2 ] ; then
			if [ ! -e $2 ] ; then
				echo "file or directory : $2 is not exists" ; exit 2
			else
				owner=$(stat -c %U $2)
				if [ $user = $owner ] ; then
					echo "the current owner is current user : $user alredy " ; exit 1
				else
					changeowner $user $2
				fi
			fi
		elif [ $# -eq 3 ] ; then
			echo "$owner"
			if [ ! -e $3 ] ; then
				echo "file or directory : $3 is not exists" ; exit 2
			else
				owner=$(stat -c %U $2)
				if [ "$2" = "$owner" ] ; then
					echo "the current owner is current user : $2 alredy " ; exit 1
				else
					echo "file owner : $owner  request change to $2"
					changeowner $2 $3
				fi
			fi
		else
			echo "option get only one value !!!" ; exit 2
		fi
		shift 2
	fi
	if [ $# -lt 2 ] ; then
	       exit 2
	fi 
	if [ $1 = "-p" ] ; then
		if [ ! -e $3 ] ; then
                        echo "file or direcotry : $2 is not exists" ; exit 2
		fi
		changepermission $2 $3
		
	fi

fi
