<#------------------------------------------------------------------------
Script   	: Holiday_Checks.psm1
Author   	: Louie Corbo
Date     	: 08/14/15
Keywords 	: Environment checks, Holiday
Comments 	: Functions envolved in checking holiday's and other process 
			: impactful Dates
--------------------------------------------------------------------------#>  

Function Holiday_Check {

	Param(
		[Parameter(Mandatory=$true)] 
		$Event_Type
	)#end Param
	
	Try {
		$Instance = "Genesis"
		$INSERT_Query  = "
		DECLARE @ret nvarchar(15)= NULL;
		EXEC @ret = POC.dbo.fnIsHoliday
		Select @ret as 'result';
		"
		$Query_response = invoke-sqlcmd -Query $INSERT_Query -ServerInstance $Instance
		If ($Query_response.result = 'N') {
			Return $false
		}
		Else {
			Return $true
		}
	}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message ('[Holiday_Check]: ' + $_)
		Exit
	}
}
