##############################################
## KMX_Services_Accounts_pwdLastSet_Report	##
## 7/10/2014                    			##
## By Louie Corbo               			##
##############################################

##############################################################################################
## Script Function:  Produces a Report of services accounts that require a password change. ##
##############################################################################################


####################
## Import Modules ##
####################

import-module ActiveDirectory


###############
## Set Paths ##
###############

$CVS_EXPORT_1 = "C:\AdminFiles\Scripts\AD Scripting\KMX_Services_Accounts_pwdLastSet_Report_$(get-date -f MM_dd_yyyy_HH_mm_ss).csv"

#################
## Main Script ##
#################

Get-ADUser -Filter {pwdLastSet -eq 0 -and PasswordNeverExpires -eq $true} -SearchBase "OU=ServiceAccounts, OU=RestrictedUsers, DC=DMX, DC=Local" | Export-Csv $CVS_EXPORT_1 -notypeinformation