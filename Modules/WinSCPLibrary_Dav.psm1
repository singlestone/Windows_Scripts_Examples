<#------------------------------------------------------------------------
Script   	: WinSCPLibrary_Dav.psm1
Author   	: Louie Corbo
Date     	: 07/31/15
Keywords 	: Secure FTP, SFTP, WinSCP
Comments 	: WinSCP Secure FTP library, Custom Development for use at Davenport & Company LLC
			: Based on the following script: https://gallery.technet.microsoft.com/Secure-FTP-Powershell-65a2f5c5 
complete WinSCP .NET support information visit http://winscp.net/eng/index.php.

--------------------------------------------------------------------------#>  

# Powershell FTP 

#requires -version 2.0

# Should be stored with other DLL's used 
$WinSCPInstallPath  = 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\DLL\'
$WinSCPnet_Path 	= 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\'
$WinSCPnet_dll 		= 'WinSCPnet.dll'
$WinSCPnet 			= $WinSCPnet_Path + $WinSCPnet_dll

Function Add-WinSCPAssembly {

	Param(
		[Parameter(Mandatory=$true)] 
		$Source
	)#end Param

	try {
               Add-Type -Path $WinSCPInstallPath\WinSCPnet.dll
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Add-WinSCPAssembly]: ' + $_)
		Exit    
	}
}#end Add-WinSCPAssembly

Function Set-SFTPSessionOption {

	Param(
		[Parameter(Mandatory=$true)]
		$HostName,
		[Parameter(Mandatory=$true)] 
		$UserName, 
		[Parameter(Mandatory=$true)]
		$Password_Path,
		[Parameter(Mandatory=$true)] 
		$SshHostKey,
		[Parameter(Mandatory=$true)] 
		$Source
	)#end Param

	try	{
		$Module_Path = 'C:\Users\lcorbo\Desktop\My Documents\Project\Neutron Scripts\CGI_401b_Disbursement\Modules\'
		Import-Module -force $Module_Path'Password_Management'
		Add-WinSCPAssembly $Source
		$sessionOptions = New-Object WinSCP.SessionOptions
		$sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
		$sessionOptions.HostName = $HostName
		$sessionOptions.UserName = $UserName
		$sessionOptions.Password = (Import-Local_Password $Password_Path $Source)
		$sessionOptions.SshHostKeyFingerprint = $SshHostKey
		$session = New-Object WinSCP.Session
		$session.Open($sessionOptions)
		Write-Host -ForegroundColor Cyan "Session Opened successfully to $($sessionOptions.hostName)..."
		return $session
	}#end Try
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Set-SFTPSessionOption]: ' + $_)
		exit
	}
}#end Set-SFTPSessionOptions

Function Close-SFTPSession {

	Param(
		[Parameter(Mandatory=$true)]
		[WinSCP.Session]$Session,
		[Parameter(Mandatory=$true)] 
		$Source
	)#end Param

	try	{
	# Disconnect, clean up
		$session.Dispose
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Close-SFTPSession]: ' + $_)
	}
}#end Close-SFTPSession       
 
Function Write-ToSFTPServer {

	Param(
		[Parameter(Mandatory=$true)]
		[WinSCP.Session]$Session,
		[Parameter(Mandatory=$true)] 
		[string]$SourcePath,
		[Parameter(Mandatory=$true)]
		[ValidateSet("Binary","Ascii","Automatic")]
		[String]$TransferMode,
		[string]$RemotePath = "./", 
		[Parameter(Mandatory=$true)]
		[string]$Source,
		[switch]$DeleteSource
	)#end Param

	try {
		# Create new TransferOptions object
		Set-Variable -Name transferOptions -value $null
		$transferOptions = New-Object WinSCP.TransferOptions

		switch($TransferMode) {
			"Binary"{$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary}
			"Ascii" {$transferOptions.TransferMode = [WinSCP.TransferMode]::Ascii}
			"Automatic" {$transferOptions.TransferMode = [WinSCP.TransferMode]::Automatic}
		}
 
		Set-Variable -name transRslts -Value $null
		$transRslts = $Session.PutFiles($SourcePath, $RemotePath, $DeleteSource, $transferOptions)
	
		# Call the TransferResults Check method to see if any errors occurred.
		if($transRslts.failures.count -gt 0)
		{
           	Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message "[Write-ToSFTPServer] - $($transRslts.Failures)"
		}
		else
		{
			# Print results
			foreach ($transfer in $transRslts.Transfers)
			{
				Write-Eventlog -LogName Application -Source $Source -EntryType Information -EventID 82 -Message ('[Write-ToSFTPServer]: Upload of {0} succeeded ' -f $transfer.FileName)
			}
		}
	return $transRslts
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Add-WinSCPAssembly]: ' + $_)
		Exit    
	}
}#end Write-ToSFTPServer

Function Read-FromSFTPServer {

	Param(
		[Parameter(Mandatory=$true)]
		[WinSCP.Session]$Session,
		[Parameter(Mandatory=$true)] 
		[string]$LocalPath,
		[Parameter(Mandatory=$true)]
		[string]$remotePath,
		[Parameter(Mandatory=$true)]
		[string]$Source,		
		[switch]$DeleteSource
	)#end Param

	try {
		# Create new TransferOptions object
		Set-Variable -Name transferOptions -value $null
		$transferOptions = New-Object WinSCP.TransferOptions
		#Possible we should take this as a param?
		$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

		Set-Variable -name transRslts -Value $null
	
		if($Session.FileExists($remotePath))
		{
			$transRslts = $Session.GetFiles($RemotePath, $LocalPath, $DeleteSource, $transferOptions)
			# Call the TransferResults Check method to see if any errors occurred.
			if($transRslts.failures.count -gt 0)
			{
				Write-Host -ForegroundColor red "[Read-FromSFTPServer] - $($transRslts.Failures)"
			}
			else
			{
				# Print results
				ForEach ($transfer in $transRslts.Transfers)
				{
					Write-Host -ForegroundColor green ("Download of {0} succeeded" -f $transfer.FileName)
				}
			}
		}#end if FileExists
		else
		{
			Write-Host -ForegroundColor red "[Read-FromSFTPServer] - ERROR: $RemotePath not found on server"
		}
		return $transRslts
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Read-FromSFTPServer]: ' + $_)
		Exit    
	}
}#end Read-FromSFTPServer 

Function Find-FromSFTPServer {

Param(
    [Parameter(Mandatory=$true)]
    [WinSCP.Session]$Session,
    [Parameter(Mandatory=$true)] 
    [string]$remotePath, 
	[Parameter(Mandatory=$true)]
    [string]$wildcard,
	[Parameter(Mandatory=$true)]	
	[string]$Source
)#end Param

	try {
		# Get list of files in the directory
		$files  = ($session.ListDirectory($remotePath)).Files |	Where-Object { $_.Name -Like $wildcard }
		return $files
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Source -EntryType Error -EventID 82 -Message ('[Find-FromSFTPServer]: ' + $_)
		Exit    
	}
}
