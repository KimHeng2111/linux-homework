#!/bin/bash
systemusers(){
	echo "=================== System Users ==================="
	echo "System Users are users with UID less than 1000"
	echo "No    UID    USERNAME              FULL NAME"
	echo "-----------------------------------------------"
	IFS=$'\n'
	i=0
	for line in $(cat /etc/passwd); do
		uid=$(echo $line | cut -d: -f3)
		i=$((i+1))
		if [ $uid -lt 1000 ] && [ $uid -ge 0 ] ; then
			username=$(echo $line | cut -d: -f1)
			fullname=$(echo $line | cut -d: -f5 | cut -d, -f1)
			printf "%-5s %-7s %-20s %-20s\n" "$i" "$uid" "$username" "$fullname"
		fi
	done
	echo "-----------------------------------------------"
	echo "System Users are users with UID less than 1000"
	echo "Note: the root user is also included" 
	echo "total $i system users found" 
}
regularuser(){
	IFS=$'\n'
	echo "=================== Regular Users ==================="
	echo "Regular Users are users with UID greater than or equal to 1000"
	echo "No    UID    USERNAME              FULL NAME"
	echo "-----------------------------------------------"
	IFS=$'\n'
	i=0
	for line in $(cat /etc/passwd); do
		uid=$(echo $line | cut -d: -f3)
		i=$((i+1))
		if [ $uid -ge 1000 ] && [ $uid -le 60000 ] ; then
			username=$(echo $line | cut -d: -f1)
			fullname=$(echo $line | cut -d: -f5 | cut -d, -f1)
			printf "%-5s %-7s %-20s %-20s\n" "$i" "$uid" "$username" "$fullname"
		fi
	done
	echo "-----------------------------------------------"
	echo "Regular Users are users with UID greater than or equal to 1000"
	echo "total $i regular users found"
}
alluser(){
	IFS=$'\n'
	echo "=================== All Users ==================="
	echo "No    UID    USERNAME              FULL NAME"
	echo "-----------------------------------------------"
	IFS=$'\n'
	i=0
	for line in $(cat /etc/passwd); do
		uid=$(echo $line | cut -d: -f3)
		i=$((i+1))
		username=$(echo $line | cut -d: -f1)
		fullname=$(echo $line | cut -d: -f5 | cut -d, -f1)
		printf "%-5s %-7s %-20s %-20s\n" "$i" "$uid" "$username" "$fullname"
	done
	echo "-----------------------------------------------"
	echo "All Users are users with UID greater than or equal to 0"
	echo "total $i all users found"
}
while true ; do
	clear
	echo "=================== System Users and Regular Users ==================="
	echo "1. Show System Users"
	echo "2. Show Regular Users"
	echo "3. Show Both System and Regular Users"
	echo "4. Exit"
	echo -n "Please enter your choice [1-4]: "
	read choice	
	case $choice in
		1) systemusers ;;
		2) regularuser ;;
		3) alluser ;;
		4) clear; exit 0 ;;
		*) echo "Your choice is invalid";;
	esac
	echo -n "Press any key to refresh or 'q' to quit..."
	read -n 1 input
	if [ "$input" = "q" ] || [ "$input" = "Q" ] ; then
		break
	fi
done