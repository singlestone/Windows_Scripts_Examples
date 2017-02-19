##################################
## Linux_user_refresh.ps1       ##
## 6/16/2014                    ##
## By Louie Corbo               ##
##################################

################################################################################################################################
## Script Function:  Queries the FAKECORP AD for Linux users and copies the defined attributes and sets them in to DMX users. ##
## Users SID and SID History to link accounts.                                                                                ##
################################################################################################################################

####################
## Import Modules ##
####################

import-module ActiveDirectory

###############
## Set Paths ##
###############

$OUTPUTFILEPATH1 = "C:\AdminFiles\Scripts\AD Scripting\LinuxUser_refreshlog_$(get-date -f MM_dd_yyyy_HH_mm_ss).log"

#########################
## Prepare environment ##
#########################


if (!(Test-Path FAKECORP:)){
	New-PSDrive -Name FAKECORP -PSProvider ActiveDirectory -Server "DCCORP07.FAKECORP.adcmax.acme.org" -Scope Global -root "//RootDSE/"
}

if (Test-Path $OUTPUTFILEPATH1){
	Remove-Item $OUTPUTFILEPATH1
}

######################
## Define Functions ##
######################

function ATTRIBUTES_UPDATE($old_user, $new_user, $old_attribute, $new_attribute_name){
	if($old_user.$old_attribute){
		## If the attribute already exists it needs to be replaced, otherwise it needs to be added, the action must be explicitly stated or else it will fail.
		if ($new_user.$new_attribute_name) {
			SET-ADUSER $new_user -replace @{$new_attribute_name=$old_user.$old_attribute}
		}
		else {
			SET-ADUSER $new_user -add @{$new_attribute_name=$old_user.$old_attribute}
		}
		$NewLine = "$(get-date -f MM_dd_yyyy_HH_mm_ss): $new_user updated $new_attribute_name with $old_user.$old_attribute from $old_user."
		$NewLine | add-content -path $OUTPUTFILEPATH1
	}
	else{
		$NewLine = "$(get-date -f MM_dd_yyyy_HH_mm_ss): $new_user does not have attribute $old_attribute from $old_user."
		$NewLine | add-content -path $OUTPUTFILEPATH1
	}
}

#################
## Main Script ##
#################

cd FAKECORP:
$CMAXCORP_LinuxUsers = Get-ADUser -Filter {msSFU30UidNumber -LIKE '*'} -Properties *
cd c:

foreach($CMAXUSER in $CMAXCORP_LinuxUsers){
	$KMXUSER = Get-ADUser -Filter {Sidhistory -eq $CMAXUSER.sid} -Properties *
	$NewLine = "$(get-date -f MM_dd_yyyy_HH_mm_ss): $KMXUSER linked to user $CMAXUSER."
	$NewLine | add-content -path $OUTPUTFILEPATH1
	ATTRIBUTES_UPDATE $CMAXUSER $KMXUSER "msSFU30Gecos" "gecos"
	ATTRIBUTES_UPDATE $CMAXUSER $KMXUSER "msSFU30GidNumber" "GidNumber"
	ATTRIBUTES_UPDATE $CMAXUSER $KMXUSER "msSFU30HomeDirectory" "unixHomeDirectory"
	ATTRIBUTES_UPDATE $CMAXUSER $KMXUSER "msSFU30LoginShell" "LoginShell"
	ATTRIBUTES_UPDATE $CMAXUSER $KMXUSER "msSFU30UidNumber" "UidNumber"
	if ($KMXUSER.UID) {
		SET-ADUSER $KMXUSER -replace @{"UID"=$KMXUSER.SamAccountName}
	}
	else {
		SET-ADUSER KMXUSER -add @{"UID"=$KMXUSER.SamAccountName}
	}
	$NewLine = "$(get-date -f MM_dd_yyyy_HH_mm_ss): $UID updated to for $DMX"
	$NewLine | add-content -path $OUTPUTFILEPATH1
}