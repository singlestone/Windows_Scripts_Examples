Param($Server_Name_param)#end Param

<#------------------------------------------------------------------------
Script   	: Eventlog_Functions.psm1
Author   	: Louie Corbo
Date     	: 07/26/16
Keywords 	: EventLog, Patching
Comments 	: Functions involved in checking Event Logs for Errors UpTime Info
--------------------------------------------------------------------------#>  

# Returns how many hours the server has been online.
Function Set-ServerSpecResults {

	Param(
		[Parameter(Mandatory=$true)]$Server_Name,
		[Parameter(Mandatory=$true)]$currentScriptDirectory
	)#end Param

	$Data_Time = Get-Date -format "yyyyMMddhhmmss"
	$OutputPath = "$currentScriptDirectory\Results\$Server_Name\ServerSpec-$Server_Name-$Data_Time.txt"
	Write-host "$OutputPath"
	Set-Location -Path "$currentScriptDirectory\ServerSpec"
	
	$ENV:TARGET_HOST = $Server_Name
	rspec .\spec\allservers\patch_spec.rb --format documentation --out "$OutputPath"
}
