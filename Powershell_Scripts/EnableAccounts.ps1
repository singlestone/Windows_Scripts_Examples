##################################
## EnableAccounts			    ##
## 6/17/2014                    ##
## By Louie Corbo               ##
##################################

###########################################################################################
## Script Function:  Disables Accounts based on CSV File defined in Variable $CVS_IMPORT ##
###########################################################################################

####################
## Import Modules ##
####################

import-module ActiveDirectory

###############
## Set Paths ##
###############

$OUTPUTFILEPATH1 = "C:\AdminFiles\Scripts\AD Scripting\Disabled_Accounts_$(get-date -f MM_dd_yyyy_HH_mm_ss).log"
$CVS_IMPORT = "C:\AdminFiles\Scripts\AD Scripting\Disabled_Service_accounts.csv"
$CVS_EXPORT_1 = "C:\AdminFiles\Scripts\AD Scripting\accountstodisable_before_$(get-date -f MM_dd_yyyy_HH_mm_ss).csv"
$CVS_EXPORT_2 = "C:\AdminFiles\Scripts\AD Scripting\accountstodisable_after_$(get-date -f MM_dd_yyyy_HH_mm_ss).csv"

#########################
## Prepare environment ##
#########################

if (!(Test-Path FAKECORP:)){
	New-PSDrive -Name FAKECORP -PSProvider ActiveDirectory -Server "DCCORP07.FAKECORP.adcmax.acme.org" -Scope Global -root "//RootDSE/"
}
cd FAKECORP:

if (Test-Path $OUTPUTFILEPATH1){
	Remove-Item $OUTPUTFILEPATH1
}

#################
## Main Script ##
#################

Search-ADAccount -AccountDisabled -UsersOnly | Export-Csv $CVS_EXPORT_1
$Disabled_LIST = Import-Csv -path $CVS_IMPORT

foreach($SamAccountName in $Disabled_LIST){
	$FAKECORP=$SamAccountName.FAKECORP
	Enable-ADAccount -Identity $FAKECORP
	$NewLine = "$FAKECORP has been Enabled"
	$NewLine | add-content -path $OUTPUTFILEPATH1
}

Search-ADAccount -AccountDisabled -UsersOnly | Export-Csv $CVS_EXPORT_2