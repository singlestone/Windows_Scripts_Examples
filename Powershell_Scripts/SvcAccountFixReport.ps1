##################################
## SvcAccountFixReport.ps1     	##
## Created: 7/11/2014         	##
## Created by: Louie Corbo    	##
##                          	##
##################################

##################################################################################################################
## Script Function:  	Produces a Report of services accounts that need to have the 'PasswordNeverExpires'		##
## 						attribute set to "True", corrects, and emails the findings to the ES Admin Team.		##
##################################################################################################################

####################
## Import Modules ##
####################

import-module ActiveDirectory

###############
## Set Paths ##
###############

$CVS_EXPORT_1 = "C:\AdminFiles\Scripts\AD Scripting\logs\KMX_Services_Accounts_pwdLastSet_Report_$(get-date -f MM_dd_yyyy_HH_mm_ss).csv"
$SVCACT_LIST = "C:\AdminFiles\Scripts\AD Scripting\logs\SVCACT_LIST.csv"
$SMTPSERVER = "outbound.acme.org"
$MSG = new-object Net.Mail.MailMessage
$MSG.From = "EnterpriseSystemsScheduledTask@entutlp02.acme.com"
$MSG.To.Add("Louis_Corbo@acme.com")


$SMTP = new-object Net.Mail.SmtpClient($smtpServer)
$SEARCHBASE = "OU=ServiceAccounts, OU=RestrictedUsers, DC=DMX, DC=Local"

if (Test-Path $SVCACT_LIST){
	Remove-Item $SVCACT_LIST
}


#################
## Main Script ##
#################

Get-ADUser -Filter {
					pwdLastSet -ne 0 
					-and (userAccountControl -eq "514" -or userAccountcontrol -eq "512")
					-and PasswordNeverExpires -eq "FALSE"
					-and SamAccountName -ne "krbtgt"
			    	} `
			-SearchBase $SEARCHBASE `
			-properties userAccountControl,`
						pwdLastSet,`
						PasswordLastSet,`
						PasswordNeverExpires `
						| 
Export-Csv $CVS_EXPORT_1 `
	-notypeinformation

$SVCLIST = Import-Csv -path $CVS_EXPORT_1 
$SVCLIST_LENGTH = $SVCLIST | Measure-Object

if($SVCLIST_LENGTH.Count -eq 0 ){
	$msg.Subject = "Daily svc acct. password expiration check (No accounts altered)."
	$msg.Body = "This daily report details service accounts in the DMX domain located in [$SEARCHBASE] that have had their initial passwords changed, but have not had their passwords set to not expire.  PLEASE NOTE: NO ACCOUNTS MET THE CRITERIA TODAY.
	
	"
	$smtp.Send($msg)
}
else{
	$NewLine = "Name"
	$NewLine | add-content -path $SVCACT_LIST

	foreach($SVCACT in $SVCLIST){
		$NAME = $SVCACT.SamAccountName
		$NAME | add-content -path $SVCACT_LIST
		SET-ADUSER $NAME -PasswordNeverExpires:$true
	}

	########################
	## Send out an E-mail ##
	########################

	$msg.Subject = "Daily svc acct. password expiration check (Corrected)."
	$msg.Body = "This daily report details service accounts in the DMX domain located in [$SEARCHBASE] that have had their initial passwords changed, but have not had their passwords set to not expire. The attachment contains a list of any accounts that meet this criteria.  PLEASE NOTE: These accounts have had the flag corrected by the script.
	
	"
	$ATT = new-object Net.Mail.Attachment($CVS_EXPORT_1)
	$msg.Attachments.Add($ATT)
	$smtp.Send($msg)
	$ATT.Dispose()
}