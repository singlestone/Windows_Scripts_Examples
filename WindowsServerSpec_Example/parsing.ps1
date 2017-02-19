
Function get-mostrecentfile {
	
    Param(
        [Parameter(Mandatory=$true)]$Pattarn,
        [Parameter(Mandatory=$true)]$Server
	)#end Param

    Set-Location "$global:ResultsDir"

    Return (Get-ChildItem | `
        where Name -like "$Pattarn*" | `
        Sort-Object -descending -property LastWriteTime)[0].Name
}

Function get-LogInfo {

	Param(   
		[Parameter(Mandatory=$true)]$Server_Name
	)#end Param

    write-host "$Server_Name"
<#
    $EventLog   = (get-mostrecentfile "Eventlogresults-" $Server_Name)
    $ServerSpec = get-mostrecentfile "ServerSpec-" $Server_Name

    $Uptime   = (Select-String -Path $EventLog -Pattern 'up').Line.Split(':')[1].Trim()
    $DownTime = (Select-String -Path $EventLog -Pattern 'offline').Line.Split(':')[1].Trim()
    $ErrorNum = (Select-String -Path $EventLog -Pattern 'error').Line.Split(':')[1].Trim()
    
    $SpecLine = (Select-String -Path $ServerSpec -Pattern 'Failed examples:').LineNumber-2
    $SpecErr  = (Select-String -Path $ServerSpec -Pattern 'failures' | Where LineNumber -eq $SpecLine).Line.Split(',').Trim('failures').Trim()[1]

    $row = $global:ServerTable.NewRow()
    $row.Server = $Server_Name  
    $row.Uptime = $Uptime 
    $row.DownTime = $DownTime
    $row.Errors = $ErrorNum
    $row.Service_Errors = $SpecErr
    $ServerTable.Rows.Add($row)
    
    #> 
}


Function New-SrvrTable {

    $TableName = "Server Status"
    $ServerStatus = New-Object system.Data.DataTable “$TableName”
    $col1 = New-Object system.Data.DataColumn Server,([string])
    $col2 = New-Object system.Data.DataColumn Uptime,([string])
    $col3 = New-Object system.Data.DataColumn DownTime,([string])
    $col4 = New-Object system.Data.DataColumn Errors,([string])
    $col5 = New-Object system.Data.DataColumn Service_Errors,([string])

    $ServerStatus.columns.add($col1)
    $ServerStatus.columns.add($col2)
    $ServerStatus.columns.add($col3)
    $ServerStatus.columns.add($col4)
    $ServerStatus.columns.add($col5)

    Return $ServerStatus
}

Function Get-StatusSrvrList {
    Set-Location "$global:currentScriptDirectory\Results\"
    $list = Get-ChildItem | Where Mode -eq 'd----' | select Name
    return $list
}

$global:currentScriptDirectory = "C:\Users\9500547\Desktop\ServerTestSet"
$global:ResultsDir = "$global:currentScriptDirectory\Results"
$global:ServerTable = New-SrvrTable

$Server_List = Get-StatusSrvrList

   get-LogInfo -Server_Name "GENAPP01D01"

   <#
foreach($Column in $Server_List)
{
   get-LogInfo -Server_Name $Column.name

   get-LogInfo -Server_Name "GENAPP01D01"
   GENAPP01D01
}

$global:ServerTable

#>