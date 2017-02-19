<#-----------------------------------------------------------------------------------------------------------------
Script   	: unit_tests.ps1 
Author   	: Louie Corbo
Date     	: 02/19/16
Keywords 	: 
Comments 	: 
------------------------------------------------------------------------------------------------------------------#>   

	# Event Type
$Event_Type = 'unittest'
	#Date
$Date = get-date -Format yyyyMMdd 
	# Prep Event Source
Try {
	If (!([System.Diagnostics.EventLog]::SourceExists('unittest')))	{
		New-EventLog -LogName Application -Source $Event_Type
	}
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Environment_Prep] $_'
	Exit
}
	# End of Prep Event Source

# Load Modules
Try {
	$Module_Path = '.\Modules\'
	Import-Module -force $Module_Path'Gnupg_Encryption'
	Import-Module -force $Module_Path'Neutron_Environment'
	Import-Module -force $Module_Path'WinSCPLibrary_Dav'

}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message ('[Module Load]' + $_)
	Exit
}
# End of Load Modules


	# Step 2. Decrypt files
Try {
	$Receive_Path 		= ".\"
	$filetype = '*.txt.pgp'
	$PGP_password_Path = ".\Passwords\Password.txt"
    $Files_Too_Dencrypt = Get-ChildItem -Path $Receive_Path -filter $filetype
    Test_Working_Directory $Event_Type $PGP_password_Path 
    Foreach ($file in $Files_Too_Dencrypt) {
   	    Decrypt_Files ($Receive_Path + $file) $PGP_password_Path $Event_Type
    }
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message ('[Step 2]: ' + $_)
	Exit
}
	# End of Step 2.