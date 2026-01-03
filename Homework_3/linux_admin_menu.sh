#!/bin/bash
while true ; do
        clear
        echo "================ Linux Administration Menu ================"
        echo "1. Create Directory Structure"
        echo "2. Create Users and Groups"
        echo "3. Set Permissions and Ownerships"
        echo "4. Show System Users"
        echo "5. Exit"
        echo -n "Your choice [1-5]: "
        read choice
        case $choice in
            1) ./create_structure.sh;continue ;;
            2) ./user_management.sh;continue ;;
            3) ./permission_setup.sh;continue ;;
            4) ./show_user.sh;continue;;
            5) clear;exit 0 ;;
            *) echo "Your choice is invalid";;
        esac
        echo -n "Press any key to refresh or 'q' to quit..."
        read -n 1 input
        if [ "$input" = "q" ] || [ "$input" = "Q" ] ; then
            break
        fi
done