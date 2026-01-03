#!/bin/bash
#catch user id and group id
user=$EUID
#this script is build for create file like regular file and directory file  
#if don't have any option or with option -t id display file like tree
#set default value of -d , -f option for false
d_opt=""
f_opt=""
help(){
	echo "Usage: $0 [-d directory_path] : create directory at directory_path"
	echo "       $0 [-f file_path]      : create regular file at file_path"
	echo "       $0 [directory_path]    : display tree of directory_path"
	echo "       $0                     : interactive mode"
}
#display tree
displaytree(){
	local dir="$1"
	for i in $(ls $dir)
	do
		if [[ -f $dir/$i ]]; then
            		echo "├── $i"
        	elif [[ -d $dir/$i ]]; then
            		echo "├── $i/"
        fi
	done
}
#function create file
createfile(){
	local ffile=$1
	if [ -e $ffile ] ; then #chek file that user input exists or not
			echo "$ffile is alredy exist !!!!" ; exit 2 #if exists display error message
	else
			if touch $ffile 2> /dev/null; then #if file can not create require to super user
					echo "Regular file: $ffile is created " #when created message to user
			else
					echo -n "your file directory is need to superuser "
					su -c "touch $ffile && chown $user $ffile" root
					echo "file $ffile is create success"
			fi
	fi

}
createdir(){
	local dfile=$1
	if [ -e $dfile ] ; then #chek file that user input exists or not
                echo "$dfile is alredy exist !!!!" ; exit 2 #if exists display error message
	else
			if mkdir $dfile 2>> test.txt ; then
					#when create is success
					echo "Directory: $dfile is crated success"
			else
					#when can not create
					echo -n "your path that you create direcotry is need superuser"
					su -c "mkdir $dfile && chown $user $dfile " root
			fi
	fi
}
#if user input any argument
if [ $# -gt 0 ] ; then
	if [[ $1 = "-h" ]] ; then
		help ; exit 0
	fi
	if [ $# -eq 1 ] ; then
		if [ -e $1 ] ; then #if user input file is exists or not
			if [ ! -d $1 ] ; then #check file is director or not
				echo "file $1 is not a directory " ; exit 2 # is not directory display message and stop
			else
				displaytree $1 ; exit 0 #it is direcotry call function displaytree with path directory
			fi
		else
			echo "Directory $1 is not exists" ; exit 2 #if file is not directory display message and stop
		fi
	fi
	while getopts ":d:f:h" opt #check option with getopts is built in command
	do
        case $opt in
                d) d_opt=true; dfile=$OPTARG;; #check if user use option -d
                f) f_opt=true; ffile=$OPTARG;; #check if user use option -f
                :) echo "-$OPTARG is require value "; exit 1;; #chekc if user use option like -d or -f and then user not input value
                *) echo "your option -$OPTARG is invalid "; help; exit 1;; #if user use invalid option
        esac
	done
	if [ $d_opt ] ; then #if user use option -d
		createdir $dfile
	elif [ $f_opt ] ; then #if user use option -f
		createfile $ffile
	fi
else
	while true ; do
		clear
		echo "====Create File Structure Menu===="
		echo "1. Create Directory"
		echo "2. Create Regular File"
		echo "3. Display Tree Structure of Directory"
		echo "4. Exit"
		echo -n "Your choice [1-4]: "
		read choice
		case $choice in
			1) echo "================= Create Directory ================"  
			   echo -n "Enter directory name with path : "
			   read dirname
			   createdir $dirname;;
			2) echo "================= Create Regular File ================"
			   echo -n "Enter file name with path : "
			   read filename
			   createfile $filename;;
			3) echo "================= Display Tree Structure ================"
			   echo -n "Enter directory name with path { . for current} : "
			   read dirname
			   if [ -e $dirname ] ; then
				if [ ! -d $dirname ] ; then
					echo "file $dirname is not a directory " ; exit 1
				else
					displaytree $dirname
				fi
			   else
				echo "Directory $dirname is not exists" ; exit 1
			   fi
			   ;;
			4) clear;exit 0 ;;
			*) echo "Your choice is invalid";;
		esac
		echo -n "Press any key to refresh or 'q' to quit..."
		read -s -n 1 input
		if [ "$input" = "q" ] || [ "$input" = "Q" ] ; then
			break
		fi
	done
fi

