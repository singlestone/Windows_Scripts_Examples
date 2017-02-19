<#------------------------------------------------------------------------
Script   	: Password_Management.psm1
Author   	: Louie Corbo
Date     	: 08/05/15
Keywords 	: Security
Comments 	: Encrypts the Local passwords and saves them to local files
			: and then decrpyts them when a password is needed.
--------------------------------------------------------------------------#>  

Function Export-Local_Password {

	Param(
		[Parameter(Mandatory=$true)] 
		$passwordASCII, 
		[Parameter(Mandatory=$true)]
		$Password_Path,
		[Parameter(Mandatory=$true)] 
		$Event_Type
	)#end Param

	Try {
		# Mandatory Framework .NET Assembly 
		Add-Type -assembly System.Security
		$Module_Path = 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\Modules\'		
		Import-Module -force $Module_Path'Neutron_Environment'
		
		# String to Crypt
		#$passwordASCII = "password"

		# String to INT Array
		$enc = [system.text.encoding]::Unicode
		$clearPWD_ByteArray = $enc.GetBytes( $passwordASCII.tochararray())

		# Crypting
		$secLevel = [System.Security.Cryptography.DataProtectionScope]::LocalMachine
		$bakCryptedPWD_ByteArray = [System.Security.Cryptography.ProtectedData]::Protect($clearPWD_ByteArray, $null, $secLevel)

		# Store in Base 64 form
		$B64PWD_ByteArray = [Convert]::ToBase64String($bakCryptedPWD_ByteArray)
		Set-Content -literalpath $Password_Path -Value $B64PWD_ByteArray
		}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message ('[Export-Local_Password] ' + $_)
		Exit
	}
}

Function Import-Local_Password {

	Param(
		[Parameter(Mandatory=$true)]
		$Password_Path,
		[Parameter(Mandatory=$true)] 
		$Event_Type
	)#end Param

	Try {
		# Mandatory Framework .NET Assembly
		Add-Type -assembly System.Security
		$Module_Path = 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\Modules\'		
		Import-Module -force $Module_Path'Neutron_Environment'
		
		# Getting from Base 64 storage
		$resCryptedPWD_ByteArray = [Convert]::FromBase64String((Get-Content -literalpath $Password_Path))

		# Decoding
		$secLevel = [System.Security.Cryptography.DataProtectionScope]::LocalMachine
		$clearPWD_ByteArray = [System.Security.Cryptography.ProtectedData]::Unprotect( $resCryptedPWD_ByteArray, $null, $secLevel )

		# Dtring from int Array
		$enc = [system.text.encoding]::Unicode
		return $enc.GetString($clearPWD_ByteArray)
		}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message ('[Import-Local_Password]: ' + $_)
		Exit
	}
}