
#Parameters

$Server = "LJC_Test"

$IP_Address = "x.x.x.x"

# VM Hardware Spec
$New_Drive_Size = 500 #This assumes a second hard drive will be attached
$Ram = 4096
$NUM_CPU = 1
$Selected_Network = "network"

# vShpere Information
$vSphere = "Dominio"
$Template_Name = "Template Location"
$Datastore = "Datastore1"

#Network configuration details.
$DNS_Server_Prime = "192.168.100.66"
$DNS_Server_Sec = "192.168.100.53"
$PrefixLength = "24"
$Gatway = "192.168.100.1"

# Domain Information
$Domain = "invest"
$OU_Path = "Servers"

#Path to Powershell modules
$PS_MODs = "\\......"

#Path to Powershell sub processes
$PS_SPs = "\\......"

#Path for Software install scripts //This might not be needed for initial script scope
#Path for Software install files //This might not be needed for initial script scope


#Path to Logfile
#$Logfile_Path = "C:\Users\lcorbo\Desktop\My Documents\Project\Server Deployment\Logfile_Test\"
$Logfile_Path = "\\investdavenport.com\davenport\HQ\IS\Support\Projects\Automated_Server_Provisioning\Logs\"
$DateStamp = (Get-Date).ToString('ssmmhhddMMyyyy')

Write-host "Starting"

Function Test_Working_Directory() {
	param(
		[string]$Directory
		);

	If (!(Test-Path -path $Directory))
	{
		Write-host "$DateStamp $Directory is not available, Please confirm path. Aborting process...."
        Exit
	}
	Elseif  (Test-Path -path $Directory)
	{
		Write-host "$DateStamp <$Directory> is accessible, proceeding."
	}
	Else
	{
		Write-host "$DateStamp The path neither exists or doesn't exist.  This message means the path check method is broken."
	}
}

Function Create_Logfile_SubFolder() {
	param(
		[string]$Directory, 
		[string]$Folder
		);
		
    If ((Test-Path -path $Directory$Folder)) {
        Write-host "$DateStamp Path already exists, Server may have been deployed before!"
		Write-host "$DateStamp I'll confirm this before deploying the template."
    }
	ElseIf (!(Test-Path -path $Directory$Folder)) {
		Write-host "$DateStamp Creating folder $Folder in location $Directory..."
        New-Item -ItemType directory -Path $Directory$Folder
		Write-host "$DateStamp ...done!"
    }
    Else {
        Write-host "$DateStamp The folder neither exists or doesn't exist.  This message means the folder check method is broken."
    }
}

Test_Working_Directory $Logfile_Path
Create_Logfile_SubFolder $Logfile_Path $Server

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Inquire"
Start-Transcript -path "$Logfile_Path$Server\$Server$DateStamp.txt" -append

	#Initial Parameters.
	Write-host "..."
	Write-host "..."
	Write-host "..."
	Write-host "Execution Time: $(Get-Date)"
	Write-host "Server name: $Server"
	Write-host "IP Address: $IP_Address"
	Write-host "..."
	Write-host " VM Hardware Spec:"
	Write-host "Applicate Drive Size $New_Drive_Size = 500"
	Write-host "Memory: $Ram"
	Write-host "# of CPUs: $NUM_CPU"
	Write-host "Network connected to: $Selected_Network"
	Write-host "..."
	Write-host "vShpere Information"
	Write-host "vSphere: $vSphere"
	Write-host "Template Used: $Template_Name"
	Write-host "Datastore: $Datastore"
	Write-host "..."
	Write-host "Network configuration details."
	Write-host "DNS Server 1: $DNS_Server_Prime"
	Write-host "DNS Server 2: $DNS_Server_Sec"
	Write-host "Prefix Length: $PrefixLength"
	Write-host "Gateway: $Gatway"
	Write-host "..."
	Write-host "Domain Information"
	Write-host "Domain: $Domain"
	Write-host "OU Path: $OU_Path"
	Write-host "..."
	Write-host "Path to Powershell modules:"
	Write-host "$PS_MODs"
	Write-host "..."
	Write-host "Path to Powershell sub processes:"
	Write-host "$PS_SPs"
	Write-host "..."
	Write-host "Path to Logfile:"
	Write-host "$Logfile_Path"
	Write-host "..."
	Write-host "..."
	Write-host "..."
	Write-host "..."	
	#import modules

Stop-Transcript