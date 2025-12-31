#!/bin/bash
#catch user id and group id
user=$EUID
#this script is build for create file like regular file and directory file  
#if don't have any option or with option -t id display file like tree
#set default value of -d , -f option for false
d_opt=false;
f_opt=false;
#display tree
displaytree(){
	local dir
	if [[ $# -eq 1 ]] && [[ -e $1 ]] ; then
		dir=$1
	else
		dir="."
	fi
	for i in $(ls $dir)
	do
		if [[ -f $dir/$i ]]; then
            		echo "├── $i"
        	elif [[ -d $dir/$i ]]; then
            		echo "├── $i/"
        fi


	done

}
#check option if don't have user input potion
#display tree in current directory
#if user input path display with path
if [ $# -eq 1 ] ; then #chek user input path or not 
	if [ -e $1 ] ; then #if user input file is exists or not
		if [ ! -d $1 ] ; then #check file is director or not
			echo "file $1 is not a directory " ; exit 2 # is not directory display message and stop
		else
			displaytree $1 #it is direcotry call function displaytree with path directory
		fi
	else
		echo "Directory $1 is not exists" ; exit 2 #if file is not directory display message and stop
	fi
elif [ $# -eq 0 ] ; then #if user is not input file
	displaytree #display with current directory
	exit 
fi

#check option that user input 
while getopts ":d:f:" opt #check option with getopts is built in command 
do
	case $opt in
		d) d_opt=true; dfile=$OPTARG;; #check if user use option -d
		f) f_opt=true; ffile=$OPTARG;; #check if user use option -f
		:) echo "-$OPTARG is require value "; exit 1;; #chekc if user use option like -d or -f and then user not input value
		*) echo "your option -$OPTARG is invalid "; exit 1;; #if user use invalid option
	esac
done
if [ $d_opt = true ] ; then #if user use option -d 
	if [ -e $dfile ] ; then #chek file that user input exists or not
		echo "$dfile is alredy exist !!!!" ; exit 2 #if exists display error message 
	else 
		if mkdir $dfile 2>> test.txt ; then
		       #when create is success
		       echo "Directory: $dfile is crated success"
	       else
		       #when can not create 
		       echo -n "your path that you create direcotry is need superuser"
		       su -c "mkdir $dfile && chown $user:users $dfile " root
		fi
	fi
fi
if [ $f_opt = true ] ; then #if user use option -f
        if [ -e $ffile ] ; then #chek file that user input exists or not
                echo "$ffile is alredy exist !!!!" ; exit 2 #if exists display error message 
        else
                if touch $ffile 2> /dev/null; then #if file can not create require to super user
			echo "Regular file: $ffile is created " #when created message to user
		else
			echo -n "your file directory is need to superuser "
			su -c "touch $ffile && chown $user:users $ffile" root
			echo "file $ffile is create success"
		fi
	fi
fi


