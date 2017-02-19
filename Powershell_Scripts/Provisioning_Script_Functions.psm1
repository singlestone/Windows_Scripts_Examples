# Provisioning Script Functions
# These functions help preparing to provision new VM Servers
# By Louie Corbo
# Tested successfully 6/03/2015

# Works 6/05/2015
Function Static_Global_Variables() {
	# Network configuration details
		$global:DNS_Server_Prime 	= 					"192.168.100.66"										# Primary DNS Address
		$global:DNS_Server_Sec 		= 					"192.168.100.53"										# Secondary DNS Address
		$global:Subnetmask	 		= 					"255.255.255.0"											# The Subnet Mask
		$global:Gateway 			= 					"192.168.100.1"											# The Network Gateway
		$global:NICNAME				=					"Ethernet"

	# Domain Information
		$global:Domain 				= 					"invest.com"									# The domain the server will be Joining
		$global:OU_Path 			= 					"OU=WSUS_test,OU=Servers,DC=invest,DC=com"		# OU path where the server will be added
		$global:Admin_Accnt			=					"Administrator"											# The local Admin Account
		$Admin_Pass					=					"password"											# The local Admin Password for the VM
		
	# Path to Logfile																							# This is where Log files related to this script will be stored
		$global:Logfile_Path		= 					"C:\Users\lcorbo\Desktop\My Documents\Project\Git_Automated_Server_Provisioning\Logs\"

	# This allows log files to have a unique name based on when it was run
		$global:DateStamp 			= 					(Get-Date).ToString('MMyyyyddhhmmss')					# 06/03/2015 13:18:07 => 20150603131807
	
	# vShpere Information
		$global:vSphere 			= 					"Domino"												# The name of the vShpere 
		$global:Template	 		= 					"2012R2DC"												# Name of the Template used when provisioning the computer		
		$global:ResourcePool		=					"UCS_Cluster1"											# Name of the Resource Pool
		$global:NetworkLB			=					"Prod 1100"
		$global:NICAPT				=					"Network adapter 1"

	# Local Credentials
		
		$global:VS_credentials = Get-Credential		

		#new-object -typename System.Management.Automation.PSCredential -argumentlist $Admin_Accnt, (ConvertTo-SecureString $Admin_Pass -AsPlainText –Force)
		
#		$PassSec = (ConvertTo-SecureString $($Admin_Pass) -AsPlainText -Force)
		$global:Local_Credentials = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $Admin_Accnt,(ConvertTo-SecureString $($Admin_Pass) -AsPlainText -Force)	
}

# Works 6/05/2015
Function Test_Working_Directory() {
	param(
		[string]$Directory
		);

	If (!(Test-Path -path $Directory))
	{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : $Directory is not available, Please confirm path. Aborting process...."
        Exit
	}
	Elseif  (Test-Path -path $Directory)
	{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : <$Directory> is accessible, proceeding."
	}
	Else
	{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : The path neither exists or doesn't exist.  This message means the path check method is broken."
	}
}

# Works 6/05/2015
Function Create_Logfile_SubFolder() {
	param(
		[string]$Directory, 
		[string]$Folder
		);
		
    If ((Test-Path -path $Directory$Folder)) {
        Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Path already exists, Server may have been deployed before!"
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : I'll confirm this before deploying the template."
    }
	ElseIf (!(Test-Path -path $Directory$Folder)) {
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Creating folder $Folder in location $Directory..."
        New-Item -ItemType directory -Path $Directory$Folder
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ...done!"
    }
    Else {
        Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : The folder neither exists or doesn't exist.  This message means the folder check method is broken."
    }
}

# Works 6/05/2015
Function Prep_Environment() {
	Test_Working_Directory $Logfile_Path
	Create_Logfile_SubFolder $Logfile_Path $Server
}

# Works 6/05/2015
Function Check_MyModule() { 
    Param([string]$name) 
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Checking Module $name Availability."
    if(-not(Get-Module -name $name)) 
    {
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Module $name not imported."
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Checking to see if module $name is imported....."
        if(Get-Module -ListAvailable | 
        Where-Object { $_.name -eq $name }) 
        { 
			Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Importing module $name....."
            Import-Module -Name $name 
			Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Done."
            return $true
        }
        else { 
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Module $name is not available!"
		return $false 
		} 
    }
    else { 
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Module $name is available."
		return $true 
	}
}

# Works 6/05/2015
Function Parameters_List() {

	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Starting..."
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Server Settings:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ================"	
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Execution Time: $(Get-Date)"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :    Server name: $Server"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :     IP Address: $IP_Address"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : VM Hardware Specs:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : =================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Application Drive Size (GB): $New_Drive_Size"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :                 Memory (MB): $Ram "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :              Number of CPUs: $NUM_CPU"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :        Network connected to: $Selected_Network"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : vShpere Information:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ===================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :         vSphere: $vSphere"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :   Template Used: $Template_Name"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :       Datastore: $Datastore"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :     ResurcePool: $ResourcePool"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Network configuration details:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : =============================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : DNS Server 1:  $DNS_Server_Prime"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : DNS Server 2:  $DNS_Server_Sec"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Subnet Mask:   $Subnetmask"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Gateway:       $Gateway"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Domain Information:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ==================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) :  Domain: $Domain"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : OU Path: $OU_Path"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Path to Powershell modules:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ==========================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : $PS_MODs"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Path to Powershell sub processes:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ================================="
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : $PS_SPs"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Path to Logfile:"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : ================"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : $Logfile_Path"
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "	
}

# Works 6/25/2015
Function Provision_Process() {
	# Display defined parameters 
		Parameters_List
		if (-not(Check_MyModule ActiveDirectory)){Exit}
	
	#Import PowerCLI_Functions
		If(!(Test-path $PS_SPs\PowerCLI_Functions.psm1)) {
			Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Critical Module not found, exiting."
			Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : No log file created."
			exit
		}
		Import-Module -force $PS_SPs\PowerCLI_Functions.psm1
		Import-Module -force $PS_SPs\Server_Administration_Task.psm1
		
		Initialize_vSphere_Connection `
			$vSphere `
			$VS_credentials
		
		Deploy_Template `
			$Server `
			$Template `
			$Datastore `
			$ResourcePool `
			$New_Drive_Size
			
		Configure_VM_First_Boot `
			$Server `
			$Ram `
			$NUM_CPU `
			$New_Drive_Size `
			$NICAPT `
			$NetworkLB

		Config_Local_HD `
			$VS_credentials `
			$Local_Credentials `
			$Server `
			$New_Drive_Letter `
			$New_Drive_Size
			
		NET_INT_CONF `
			$IP_Address `
			$NICNAME `
			$Subnetmask `
			$Gateway `
			$DNS_Server_Prime `
			$DNS_Server_Sec `
			$VS_credentials `
			$Local_Credentials `
			$Server `
			$NICAPT `
			$vSphere			

	#Configure Server
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "	
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : "
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : End of Script."
		Write-host ""
}
