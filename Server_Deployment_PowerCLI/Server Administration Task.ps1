# Administration task function for configuring Windows 2012 servers.
# Written by Louie Corbo
# Still being Tested, do not use in production.
# Date 5/11/2015

# Configures a Network Device to a static IPaddress. 
Function NET_INT_CONF() {
	param(
		[string]$IP_Address_LF,
		[string]$InterfaceAlias_LF,
		[Int]$PrefixLength_LF,
		[string]$Gatway_LF,
		[string]$DNS_Server_Prime_LF,
		[string]$DNS_Server_Sec_LF,
		);

New-NetIPAddress `
	–IPv4Address     $IP_Address_LF `
	–InterfaceAlias  $InterfaceAlias_LF `
	–PrefixLength    $PrefixLength_LF `
	-DefaultGateway  $Gatway_LF 

Set-DnsClientServerAddress `
	-InterfaceAlias  $InterfaceAlias_LF `
	-ServerAddresses $DNS_Server_Prime_LF `
					 $DNS_Server_Sec_LF
}	

# Returns true if Parameter can be used to create a new volume, otherwise returns false.
Test_Drive() {
	param(
		##Expects Format "D:\"
		[string]$Drive_Letter_LF
	)	
	If !(($Drive_Letter_LF.length -ne 3) -and ($Drive_Letter.Substring(1) -ne ':\')) {
		Write-Host "The Drive Letter Parameter was not properly formatted.  Cancelling Task."
		Return $false
	}
    ElseIf (Test-Path $Drive_Letter) {
		Write-Host "Drive $Drive_Letter already exists."
		Return $false
	}
	Return True$
}

# PowerShell Script to Display File Size
Function DiskSize_Cleanup() {
[cmdletbinding()]
	Param ([long]$Type)
	If ($Type -ge 1TB) {[string]::Format("{0:0.00} TB", $Type / 1TB)}
	ElseIf ($Type -ge 1GB) {[string]::Format("{0:0.00} GB", $Type / 1GB)}
	ElseIf ($Type -ge 1MB) {[string]::Format("{0:0.00} MB", $Type / 1MB)}
	ElseIf ($Type -ge 1KB) {[string]::Format("{0:0.00} KB", $Type / 1KB)}
	ElseIf ($Type -gt 0) {[string]::Format("{0:0.00} Bytes", $Type)}
	Else {""}
} # End of function

# Function that takes Integer that sets the size of a hard drive and converts it to a string.  This will make is easer to validate the configure is correct.
Function Disk_Size_to_String() {
	param(
		[INT]$DiskInt
		)
	Return [string]::Format("$Diskint.00 GB")
}

# Configures the Application Data Drive
Function App_Drive_CONF() {
	param(
		[string]$Drive_Letter_LF,
		[INT]$Drive_Size_LF
		);
	
	If !(Test_Drive $Drive_Letter_LF) {
		Write-Host "The $Drive_Letter_LF is not valid, the application drive can be configured."
		Return
	}
	
	Where (Number -eq $Disk_ID) -and  | `
		Initialize-Disk -PartitionStyle MBR -PassThru | `
		New-Partition -DriveLetter $Drive_Size_LF.Substring(0,1) -UseMaximumSize | `
		Format-Volume -FileSystem NTFS -NewFileSystemLabel "App Drive" -Confirm:$false	
}