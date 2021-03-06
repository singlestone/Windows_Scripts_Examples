# This is a bulk AD User Enable script written by Rob Sanderson.
# C:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe

# Changing directory to where modules are stored.
cd .\Modules\SIDHistory\SIDHistory

# Importing modules
Import-module ActiveDirectory
Import-Module .\Modules\SIDHistory.psm1
# Sets the Date/Time Variable to be used for file creation
# @echo off

#sets the date variable
set mydatetime=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~-11,2%%time:~-8,2%
$date = Get-Date -f "yyyyMMdd"
$datetime = Get-Date -f "yyyyMMdd_hhmm"
# echo $date
# Add-Content $SaveFilePath$FileName '$date'

# Sets the variables Used during the script.
$ListFilePath = ".\Modules\SIDHistory\SIDHistory"
$SaveFilePath = ".\Modules\SIDHistory\SIDHistory\_Completed\"
$FileName = "Enabled_Users_$date.txt"


#AD Account Enable for users

$accounts = Get-Content $ListFilePath\sid-users.txt

foreach ($account in $accounts){

# This script will Enable the AD Users.
Enable-ADAccount -Identity $account | Out-File $SaveFilePath$FileName -Append
}

"End of Run $datetime" | Out-File $SaveFilePath$FileName -Append
