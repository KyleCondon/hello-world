#!/bin/bash

#####################
#Made by: Kyle Condon
#####################


CD_APP="/Library/PCPS/apps/CocoaDialog.app/Contents/MacOS/CocoaDialog"
JAMF="/usr/local/bin/jamf"
Box=""
UserSelection=""
NewUserName=""


function NameChange {
	ADSearch=""

	Box=`$CD_APP inputbox \
	--title "Reassign Your Mac" \
	--icon "user" \
	--informative-text "Input new user (FirstName.LastName) 

NOTE: If you have a number at the end of your Username, please include it." \
	--button1 "Assign" \
	--button2 "Cancel" \
	--value-required \
	--empty-text "The User Name field cannot be empty."`

	UserSelection=`echo $Box | awk '{print $1}'`
	NewUserName=`echo $Box | awk '{print $2}'`
}

NameChange

if [ $UserSelection == "2" ]; then
	exit 0
fi

if [ $UserSelection == "1" ]; then
	ADSearch=`dscl /Active\ Directory/POLK-FL/All\ Domains -read /Users/$NewUserName | grep -w "RecordName:" | awk '{print $2}'`

	if [[ $ADSearch == "" ]]; then
		while [[ $ADSearch == "" ]]; do
			$CD_APP msgbox \
		  	--title "Error" \
		  	--icon "caution" \
		  	--text "Invalid User!" \
		  	--informative-text "User \"$NewUserName\" was not found! Please Try Again." \
		  	--button1 "OK"

		  	NameChange

		  	if [[ $UserSelection == "1" ]]; then
		  		ADSearch=`dscl /Active\ Directory/POLK-FL/All\ Domains -read /Users/$NewUserName | grep -w "RecordName:" | awk '{print $2}'`
		  	else
		  		exit 0
		  	fi
		  done
		fi

	if [[ $ADSearch == "$NewUserName" ]]; then
		$JAMF recon -endUsername $NewUserName
	fi
fi

exit 0