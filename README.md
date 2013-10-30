Set EFI Password
----------------


This script allows the Casper user to set, change and remove an EFI password from computer(s).

I use this as it's a little more flexible than JAMF's solution. aka It uses setregproptool straight from the Recovery partition rather than having to continually package the correct version and deploy it to the computer.

Instructions
------------

1) Add the script to your JSS.
2) Change the script parameters to something more readable.
3) When calling the script you must specify the following information:

Parameter 4: Operating Mode - This tells the script whether to set, change or remove a password.
Acceptable inputs are "initial", "change" or "remove".

Parameter 5: New Password - This is the new password you wish to give the system

Parameter 6: Old Password - Required for password changes and removal

Parameter 7: Security Mode - This is the mode that the EFI password will operate in.
(This option is required for "initial" and "change" operating modes)
Acceptable inputs are "full" and "command".

"full" will apply the EFI password to the entire computer. This will prevent ANY booting without a valid password!
"command" will apply the EFI password to the boot picker. This will allow booting to the selected startup disk but nothing else!

Be careful with this! This password is stored in a separate secure chip on Apple's computers past 2010 and if you forget, it's a trip to the Apple Store to get it reset.
