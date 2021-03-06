<#------------------------------------------------------------------------
Script   	: SQL_connection.ps1
Author   	: Louie Corbo
Date     	: 02/19/16
Keywords 	: Environment checks.
Comments 	: Functions envolved in checking holiday's and other process 
			: impactful Dates
--------------------------------------------------------------------------#>  



Function Holiday_Check {

	Param(
		[Parameter(Mandatory=$true)] 
		$Event_Type
	)#end Param
	
	Try {
		$Instance = "Servername"
		$INSERT_Query  = "
		DECLARE @ret nvarchar(15)= NULL;
		EXEC @ret = POC.dbo.fnIsHoliday
		Select @ret as 'result';
		"
		$Query_response = invoke-sqlcmd -Query $INSERT_Query -ServerInstance $Instance
		Return $Query_response.result
		}
	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 82 -Message '[Holiday_Check] $_'
		Exit
	}
}


Holiday_Check testrun




<#
$INSERT_Query = " 
SELECT [Date_Key]
      ,[Holiday]
      ,[Month_End]
  FROM [POC].[dbo].[dimDate]
  Where [Date_Key] = DATEADD(day, DATEDIFF(day, 1, GETDATE()), 0) or
		[Date_Key] = DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0)
        GO
"        
#>