##################################
## CheckAccounts			    ##
## 7/30/2014                    ##
## By Louie Corbo               ##
##################################


####################
## Import Modules ##
####################

import-module ActiveDirectory

###############
## Set Paths ##
###############


$CVS_IMPORT = ".\lists\userlist.csv"

#########################
## Prepare environment ##
#########################

if (!(Test-Path domain:)){
	New-PSDrive -Name CMAXCORP -PSProvider ActiveDirectory -Server "ADserver" -Scope Global -root "//RootDSE/"
}

cd CMAXCORP:

#################
## Main Script ##
#################

$USERS_LIST = Import-Csv -path $CVS_IMPORT

foreach($SamAccountName in $USERS_LIST){
	$SamAccountName = $SamAccountName.SamAccountName
	$Status = Get-ADUser $SamAccountName
	$NAME = $Status.SamAccountName
	$Disabled = $Status.Enabled
	ECHO "$NAME $Disabled"
	}
L: