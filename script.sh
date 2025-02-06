#!/bin/bash

users_folder="$HOME/.config/opera/users"

if [ ! -d "$users_folder" ]; then
    mkdir -p $users_folder
    #zenity --error --text="User folder not found: $users_folder"
    #exit 1
fi

declare -a users=()

for folder in "$users_folder"/*; 
    do 
        if [ -d "$folder" ]; then
            profile_img_path="$folder/profile_img.jpg"
            user_name=$(basename "$folder")
            # Ensure the profile image exists, otherwise use a default icon
            if [ ! -f "$profile_img_path" ]; then
                profile_img_path="/usr/share/icons/gnome/48x48/emotes/face-smile.png"
            fi
            users+=("$profile_img_path")
            users+=("$user_name")
            users+=("$folder")
            echo ${#users[@]}; 
        fi
    done

# Ensure the list is not empty
if [ ${#users[@]} -eq 0 ]; then
    zenity --info --text="No users found in $users_folder"
    exit 0
fi

selection=$(zenity --list --title="Select User" --text="Select or Create User" --imagelist --ok-label=Open --cancel-label=Close --extra-button="Add User" --print-column=3 --separator=" | " --width=600 --height=400 \
       --column="Profile Image" \
       --column="User Name" \
       --column="Folder" \
       "${users[@]}")


case $? in
    0)
        echo "Executing: opera --user-data-dir=\"$selection\""
        opera --user-data-dir="$selection"
        ;;
    1)
        if [[ $selection -eq "" ]];then
            echo "Close";
        else
            name=$(zenity --forms --title="User Information" --ok-label="Next" --text="Enter User Name" \
            --add-entry="User Name")
            if [[ -z $name ]]; then
                zenity --error --text="Username Cannot be Empty"
                exit 1
            else
                image=$(zenity --file-selection --title="Select Profile Image" --file-filter="*.jpg")
                user_directory="$users_folder/$name"
                mkdir -p "$user_directory"
                destination_directory="$user_directory/profile_img.jpg" 
                if [[ -d $user_directory ]]; then
                    cp "$image" "$destination_directory"
                    convert "$user_directory/profile_img.jpg" -resize 50x50 "$user_directory/profile_img.jpg"
                else
                    echo "User directory was not created."
                fi
            fi
            opera --user-data-dir="$user_directory"
        fi
        ;;
esac

