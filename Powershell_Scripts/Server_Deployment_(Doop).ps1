# Server Deployment Script
# Author: Louie Corbo	Date: 06/03/2015
#Parameters
	$global:Server 				= 				"Doop"																		# VM Server Name.
	$global:IP_Address 			= 				"192.168.100.122"															# VM Server IPv4 Address.

# VM Hardware Spec
	$global:New_Drive_Size 		= 				500 #This assumes a second hard drive will be attached						# This assumes a second hard drive will be attached, size in GB.
	$global:New_Drive_Letter	= 				"E:\"																		# This is what Drive the application drive will have assigned.
	$global:Ram 				= 				8192																		# Memory in MB.
	$global:NUM_CPU 			= 				2																			# The number of CPU's assigned to VM Server.
	$global:Datastore 			= 				"N2_HSATA_NFS2"																# Name of the Datastore used. (Where the server will be stored.)

# Path to Powershell modules																								# This is where Powershell modules used in this script will be stored.
	$global:PS_SPs				=				"C:\Users\lcorbo\Desktop\My Documents\Project\Git_Automated_Server_Provisioning\Power_Modules"
	
If(	!(Test-path $PS_SPs\Provisioning_Script_Functions.psm1)) {
	Write-host "$PS_SPs\Provisioning_Script_Functions.psm1 is not available, Exiting"
	Exit
}
Else {
	Add-PSSnapin VMware.VimAutomation.Core
	import-module $PS_SPs\Provisioning_Script_Functions.psm1
	Static_Global_Variables

	Start-Transcript -path "$Logfile_Path$Server\$Server$DateStamp.txt" -append
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Starting"
		Prep_Environment
		Provision_Process
	Stop-Transcript
}	
