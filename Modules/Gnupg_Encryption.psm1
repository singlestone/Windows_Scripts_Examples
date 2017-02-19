<#------------------------------------------------------------------------
Script   	: Gnupg_Encryption.psm1
Author   	: Louie Corbo
Date     	: 08/04/15
Keywords 	: Gnupg
Comments 	: Used for encypting files.
--------------------------------------------------------------------------#>  

Function Get-Password_Management {
	$Module_Path = C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\Modules\
	Import-Module -force $Module_Path'Password_Management'
}

Function Encrypt_Files {

	Param(
		[Parameter(Mandatory=$true)]
		$Files_Too_Encrypt,
		[Parameter(Mandatory=$true)] 
		$Recipient,
		[Parameter(Mandatory=$true)] 
		$Event_Type
	)#end Param
	
	Try {
			& gpg `
					--yes `
					--recipient           $Recipient `
					--compress-algo       1 `
					--cipher-algo         cast5 `
					--encrypt             $Files_Too_Encrypt
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message ('[Encrypt_Files]: ' + $_)
		Exit
	}
}

Function Decrypt_Files {

	Param(
		[Parameter(Mandatory=$true)]
		$File_Too_Decrypt,
		[Parameter(Mandatory=$true)] 
		$Password_Path,
		[Parameter(Mandatory=$true)]
		$Event_Type
		)
		
	Try {
		$Module_Path = 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\Modules\'
		Import-Module -force $Module_Path'Password_Management'
		$Passphrase = Import-Local_Password $Password_Path $Event_Type
		write-host $File_Too_Decrypt.trimEnd('.pgp')
				
		& gpg `
				--yes `
				--passphrase $Passphrase `
				-o $File_Too_Decrypt.trimEnd('.pgp') `
				--decrypt $File_Too_Decrypt
				}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message ('[Decrypt_Files]: ' + $_)
		Exit
	}		
}