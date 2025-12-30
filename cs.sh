#!/bin/bash
#catch user id and group id
user=$EUID
echo "userID :$user"
#this script is build for create file like regular file and directory file  
#if don't have any option or with option -t id display file like tree
#set default value of -d , -f option for false
d_opt=false;
f_opt=false;
#check package tree for display tree
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
            		echo "|--- $i"
        	elif [[ -d $dir/$i ]]; then
            		echo "|--- $i/"
        fi


	done

}

if [ $# -eq 1 ] ; then
	if [ -e $1 ] ; then 
		if [ ! -d $1 ] ; then
			echo "file $1 is not a directory " ; exit 2
		else
			displaytree $1
		fi
	else
		echo "Directory $1 is not exists" ; exit 2
	fi
elif [ $# -eq 0 ] ; then
	displaytree
	exit 
fi

#check option that user input 
while getopts ":d:f:" opt
do
	case $opt in
		d) d_opt=true; dfile=$OPTARG;;
		f) f_opt=true; ffile=$OPTARG;;
		:) echo "-$OPTARG is require value "; exit 1;;
		*) echo "your option -$OPTARG is invalid "; exit 1;;
	esac
done
if [ $d_opt = true ] ; then
	if [ -e $dfile ] ; then
		echo "$dfile is alredy exist !!!!" ; exit 2
	else 
		mkdir $dfile; 
		echo "Directory: $dfile is created "
	fi
fi
if [ $f_opt = true ] ; then
        if [ -e $ffile ] ; then
                echo "$ffile is alredy exist !!!!" ; exit 2
        else
                touch $ffile;
                echo "Regular file: $ffile is created "
        fi
fi


