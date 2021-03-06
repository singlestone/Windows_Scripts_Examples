
Import-Module -force '.\Modules\Gnupg_Encryption.psm1'
# Event Type
$Event_Type = 'encrypttest'

# Files to Send
$toSend_Path = ".\"
$filetype = "*.txt"
$Files_Too_Encrypt = $toSend_Path + $filetype
$Recipient = 'email@email.com'


If (!([System.Diagnostics.EventLog]::SourceExists('encrypttest')))	{
	New-EventLog -LogName Application -Source 'encrypttest'
}

Encrypt_Files $Files_Too_Encrypt $Recipient $Event_Type

#Encrypt_Files $Files_Too_Encrypt $Recipient $Event_Type


