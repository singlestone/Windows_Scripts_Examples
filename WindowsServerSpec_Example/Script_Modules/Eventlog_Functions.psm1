<#------------------------------------------------------------------------
Script   	: Eventlog_Functions.psm1
Author   	: Louie Corbo
Date     	: 07/26/16
Keywords 	: EventLog, Patching
Comments 	: Functions involved in checking Event Logs for Errors UpTime Info
--------------------------------------------------------------------------#>  


# Returns how many hours the server has been online.
Function Get-UpTime {

	Param(
		[Parameter(Mandatory=$true)]$Server_Name
	)#end Param

    $LasBoot = Get-EventLog -ComputerName $Server_Name -newest 1  -LogName System -Source "EventLog" -InstanceID 2147489653
    $StartDate = GET-DATE $LasBoot.TimeGenerated
    $UpTime = NEW-TIMESPAN -Start $StartDate -End (GET-DATE)

    return $UpTime.TotalHours
}

# Returns how many minutes the server was offline the last time it was rebooted/turned off.
Function Get-DownTime {

	Param(
		[Parameter(Mandatory=$true)]$Server_Name
	)#end Param

    $LasBoot = Get-EventLog -ComputerName $Server_Name -newest 1  -LogName System -Source "EventLog" -InstanceID 2147489653
	$LasShut = Get-EventLog -ComputerName $Server_Name -newest 1  -LogName System -Source "EventLog" -InstanceID 2147489654
	$Shutdown = GET-DATE $LasShut.TimeGenerated
    $Startup = GET-DATE $LasBoot.TimeGenerated
    $DownTime = NEW-TIMESPAN -Start $Shutdown -End $Startup

    return $DownTime.TotalMinutes
}

Function Get-ErrorsSinceBoot{

	Param(
		[Parameter(Mandatory=$true)]$Server_Name
	)

    $LasBoot = `
        Get-EventLog `
            -ComputerName $Server_Name `
            -newest 1 `
            -LogName System `
            -Source "EventLog" `
            -InstanceID 2147489653

    $LastestLog = `
        Get-EventLog `
            -ComputerName $Server_Name `
            -newest 1 `
            -LogName System

    $Application_Err_Log = `
        Get-EventLog `
            -ComputerName $Server_Name `
            -LogName Application `
            -EntryType Error `
            -newest 20 | `
            Where-Object {
                ($_.TimeGenerated -ge $LasBoot.TimeGenerated)
            }

    $System_Err_Log = `
        Get-EventLog `
            -ComputerName $Server_Name `
            -LogName System `
            -EntryType Error `
            -newest 20 | `
            Where-Object {
                ($_.TimeGenerated -ge $LasBoot.TimeGenerated)
            }

    $TableName = "Error List"
    $ERROR_LIST = New-Object system.Data.DataTable “$TableName”
    $col1 = New-Object system.Data.DataColumn List,([string])
    $col2 = New-Object system.Data.DataColumn Index,([string])
    $col3 = New-Object system.Data.DataColumn Time,([string])
    $col4 = New-Object system.Data.DataColumn EntryType,([string])
    $col5 = New-Object system.Data.DataColumn Source,([string])
    $col6 = New-Object system.Data.DataColumn InstanceID,([string])
    $col7 = New-Object system.Data.DataColumn Message,([string])

    $ERROR_LIST.columns.add($col1)
    $ERROR_LIST.columns.add($col2)
    $ERROR_LIST.columns.add($col3)
    $ERROR_LIST.columns.add($col4)
    $ERROR_LIST.columns.add($col5)
    $ERROR_LIST.columns.add($col6)
    $ERROR_LIST.columns.add($col7)

    $row = $ERROR_LIST.NewRow()

    foreach($Line in $Application_Err_Log)
    {
    	$row = $ERROR_LIST.NewRow()
    	$row.List = "Application"
    	$row.Index = $Line.index
    	$row.Time = $Line.TimeGenerated
    	$row.EntryType = $Line.EntryType
    	$row.Source = $Line.Source
    	$row.InstanceID = $Line.InstanceID
    	$row.Message = $Line.Message
    	$ERROR_LIST.Rows.Add($row)
    }

    foreach($Line in $System_Err_Log)
    {
    	$row = $ERROR_LIST.NewRow()
    	$row.List = "System"
	    $row.Index = $Line.index
    	$row.Time = $Line.TimeGenerated
    	$row.EntryType = $Line.EntryType
	    $row.Source = $Line.Source
	    $row.InstanceID = $Line.InstanceID
    	$row.Message = $Line.Message
    	$ERROR_LIST.Rows.Add($row)
    }
    Return $ERROR_LIST 
}

Function Set-EventlogResults{

	Param(
		[Parameter(Mandatory=$true)]$ResultsDir,
		[Parameter(Mandatory=$true)]$Server_Name		
	)
	
	$Data_Time = Get-Date -format "yyyyMMddhhmmss"
		
	$OutputPathdir =  "$ResultsDir\$Server_Name"
	$OutputPath = "$OutputPathdir\Eventlogresults-$Server_Name-$Data_Time.txt"
	$OutputPathcsv = "$OutputPathdir\Eventlogerrors-$Server_Name-$Data_Time.csv"
			
	If (!(Test-Path -path $OutputPathdir))
	{	
		New-Item $OutputPathdir -type directory
	}
		
	$UpTime_Output =   ("{0:N2}" -f (Get-UpTime $Server_Name))
	$DownTime_Output = ("{0:N2}" -f (Get-DownTime $Server_Name))
	$UpTime_Output =   ("{0:N2}" -f (Get-UpTime $Server_Name))
	$Error_Output = (Get-ErrorsSinceBoot $Server_Name) | Select Time, Source, Message, List, EntryType, InstanceID, Index
	$ErrNum = $Error_Output.count

	"Server $Server_Name has been up for (hours): $UpTime_Output" 				| Out-File -FilePath $OutputPath -append
	"Server $Server_Name was offline for (Minutes): $DownTime_Output"			| Out-File -FilePath $OutputPath -append
	"Server $Server_Name was the following errors since the last boot: $ErrNum"	| Out-File -FilePath $OutputPath -append
	$Error_Output | Export-Csv -notype -Path $OutputPathcsv
}






