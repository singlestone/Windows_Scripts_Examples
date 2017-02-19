<#------------------------------------------------------------------------
Script   	: Neutron_Environment.psm1
Author   	: Louie Corbo
Date     	: 08/04/15
Keywords 	: Local Environment
Comments 	: Used for tasks common to scripts run on Server Neutron.
--------------------------------------------------------------------------#>  

Function Test_Working_Directory {
	
	Param(
		[Parameter(Mandatory=$true)] 
		$EventID, 
		[Parameter(Mandatory=$true)]
		$Directory	
	)#end Param

	If (!(Test-Path -path $Directory))
	{
		Write-Eventlog -LogName Application -Source $EventID -EntryType Error -EventID 54 -Message ('[Test_Working_Directory]: Path ' + $Directory + ' is unavailable.')
		Return $false
	}
	Else {
		Return $true
	}
}

