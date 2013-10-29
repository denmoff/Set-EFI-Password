#!/bin/bash

# Script to implement an EFI password policy on a Casper Mac running 10.8 or better.

# Author: r.purves@arts.ac.uk
# Version 1.0 : 18-10-2013 - Initial version
# Version 1.1 : 29-10-2013 - Moved Recovery HD mount/dismount into their own functions for easy access
# Version 1.2 : 29-10-2013 - OS Version checking because Recovery path changes

# Set up path variables for easy access and change

MLtoolpath="/Volumes/Mac OS X Base System/Applications/Utilities/Firmware Password Utility.app/Contents/Resources/"
MLbasesysmnt="/Volumes/Mac OS X Base System/"

MVtoolpath="/Volumes/OS X Base System/Applications/Utilities/Firmware Password Utility.app/Contents/Resources/"
MVbasesysmnt="/Volumes/OS X Base System/"

basesyspath="/Volumes/Recovery HD/com.apple.recovery.boot/BaseSystem.dmg"
recoverypath="Recovery HD"

# Set up working variables from info passed to the script

# This will determine how the script functions.
# Accepted inputs are as follows:
# initial	- This will install the first EFI password on the system. This requires the security mode to be supplied.
# change	- This will change the EFI password as long as the correct old password is supplied.
# remove	- This will remove the EFI password as long as the correct old password is supplied.
operatingmode=$4

# Get password details in the next two variables
newpassword=$5
oldpassword=$6

# Get the security mode. Required for the "initial" operating mode.
# Acceptable inputs are as follows:
# full		- This will require password entry on every boot
# command	- This only requires password entry if boot picker is invoked with alt key.
securitymode=$7

# Ok now let's set up the functions in bash to open and close the recovery partition. OS specific.

function MLopenrecovery {
	/usr/sbin/diskutil mount "$recoverypath"
	/usr/bin/hdiutil attach -quiet "$basesyspath"
}

function MLcloserecovery {
	/usr/bin/hdiutil detach "$basesysmnt"
	/usr/sbin/diskutil unmount "$recoverypath"
}

function MVopenrecovery {
	/usr/sbin/diskutil mount "$recoverypath"
	/usr/bin/hdiutil attach -quiet "$basesyspath"
}

function MVcloserecovery {
	/usr/bin/hdiutil detach "$basesysmnt"
	/usr/sbin/diskutil unmount "$recoverypath"
}

# Which OS is this running on?

osvers=$( sw_vers -productVersion | awk -F. '{print $2}' )

# First of all, check the OS to see if this is supported or not. Less than 10.8 is not supported.

if [[ ${osvers} -lt 8 ]];
then
	echo "Unsupported OS version detected. Terminating script operation."
	exit 1
fi

# Now depending on specified mode, sanity check and run the appropriate commands

case "$operatingmode" in

	initial)
		# Check to see if the security mode has been specified properly. Exit if not as command will fail.

		if [[ "$securitymode" == "" ]]; then
			echo "Error: Missing security mode in policy. e.g. full"
			exit 1
		fi		
		
		if [[ "$securitymode" != "full" || "$securitymode" != "command" ]]; then
			echo "Error: Incorrect security mode specified in policy. e.g. full"
			exit 1
		fi				

		# Mount the Recovery partition

		if [[ ${osvers} -eq 8 ]];
		then
			MLopenrecovery
		elif [[ ${osvers} -eq 9 ]];
			MVopenrecovery
		else
			echo "Error: Mount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi
					
		# Enable the EFI password

		$toolpath/setregproptool -p $newpassword -m $securitymode
		
		# Unmount the Recovery partition
		
		if [[ ${osvers} -eq 8 ]];
		then
			MLcloserecovery
		elif [[ ${osvers} -eq 9 ]];
			MVcloserecovery
		else
			echo "Error: Dismount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi

	;;
	
	change)
		# Check if new password has been specified properly.
		
		if [[ "$newpassword" == "" ]]; then
			echo "Error: Missing new password in policy."
			exit 1
		fi			

		# Check if old password has been specified properly.
		
		if [[ "$oldpassword" == "" ]]; then
			echo "Error: Missing old password in policy."
			exit 1
		fi			

		# Mount the Recovery partition

		if [[ ${osvers} -eq 8 ]];
		then
			MLopenrecovery
		elif [[ ${osvers} -eq 9 ]];
			MVopenrecovery
		else
			echo "Error: Mount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi

		# Change the EFI password
		
		$toolpath/setregproptool –p $newpassword -o oldpassword
		
		# Unmount the Recovery partition
		
		if [[ ${osvers} -eq 8 ]];
		then
			MLcloserecovery
		elif [[ ${osvers} -eq 9 ]];
			MVcloserecovery
		else
			echo "Error: Dismount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi
		
	;;
	
	remove)
		# Check if old password has been specified properly.
		
		if [[ "$oldpassword" == "" ]]; then
			echo "Error: Missing old password in policy."
			exit 1
		fi				

		# Mount the Recovery partition

		if [[ ${osvers} -eq 8 ]];
		then
			MLopenrecovery
		elif [[ ${osvers} -eq 9 ]];
			MVopenrecovery
		else
			echo "Error: Mount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi
	
		# Remove the EFI password
		
		$toolpath/setregproptool –d –o oldpassword

		# Unmount the Recovery partition
		
		if [[ ${osvers} -eq 8 ]];
		then
			MLcloserecovery
		elif [[ ${osvers} -eq 9 ]];
			MVcloserecovery
		else
			echo "Error: Dismount Recovery Partition: I've no idea what this OS version is! "${osvers}
			exit 1
		fi
			
	;;
	
	*)
		# This should only activate if the operating mode hasn't been specified properly.
		echo "Error: Incorrect operating mode specified in policy. e.g. initial, change or remove"
	;;
esac

# All done!

exit 0