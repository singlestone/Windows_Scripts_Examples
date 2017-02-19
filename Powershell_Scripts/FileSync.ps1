<#-----------------------------------------------------------------------------------------------------------------
Script   	: FileSync.ps1 
Author   	: Louie Corbo
Date     	: 12/30/15
Keywords 	: FileSync, ROBOCOPY, Drupal
Comments 	: 
------------------------------------------------------------------------------------------------------------------#>   

	# Event Type
$Event_Type = 'File Sync'
	#Date
$Date = get-date -Format yyyyMMddhhmmss
	# Prep Event Source

$LOG_PATH = 'C:\Users\Getfiles\Documents'
$Source = 'E:\wwwroot'
$Rocky_I =  '\\server1\e\wwwroot'
$Rocky_II = '\\server2\e\wwwroot'

	
Try {
	If (!([System.Diagnostics.EventLog]::SourceExists('Drupal File Sync')))	{
		New-EventLog -LogName Application -Source $Event_Type
	}
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Environment_Prep] $_'
	Exit
}
	# End of Prep Event Source

Function Copy_Files {

	Param(
		[Parameter(Mandatory=$true)] 
		$Event_Type_CF,
		[Parameter(Mandatory=$true)] 
		$LOG_PATH_CF,
		[Parameter(Mandatory=$true)] 
		$Source_CF,
		[Parameter(Mandatory=$true)] 
		$Dest_CF
	)#end Param

	Try {
        $Robocopy_Log_CF = ROBOCOPY $Source_CF $Dest_CF /mir /fft 
        Log_parse $Event_Type_CF $Robocopy_Log_CF
    }

     Catch [Exception] {
        Write-Eventlog -LogName Application -Source $Event_Type_CF -EntryType Error -EventID 32 -Message ('[Copy_Files]: ' + $_)
		Exit
	}
}

Function Log_parse {

	Param(
		[Parameter(Mandatory=$true)] 
		$Event_Type_LP,
		[Parameter(Mandatory=$true)] 
		$Robocopy_Log_LP

	)#end Param
	
	Try {
            $Log_Line = $Robocopy_Log_LP.split("`n") | Select-Object -Last 11 | where {$_ -ne ""} | where {$_.Split()[3] -ne "Speed"}
            $Header = $Log_Line | Select-Object -index ($Log_Line.count -6) #Header
            $Dirs = $Log_Line | Select-Object -index ($Log_Line.count -5) #Dirs
            $Files =  $Log_Line | Select-Object -index ($Log_Line.count -4) #Files
            $Bytes = $Log_Line | Select-Object -index ($Log_Line.count -3) #Bytes
            $End_Time = $Log_Line | Select-Object -index ($Log_Line.count -2) #Ended
   
            $Dirs_Copied = ($Dirs.split() | where {$_ -ne ""}) | Select-Object -Index 3
            $Dirs_Failed = ($Dirs.split() | where {$_ -ne ""}) | Select-Object -Index 6          
            $Files_Copied = ($Files.split() | where {$_ -ne ""}) | Select-Object -Index 3
            $Files_Failed = ($Files.split() | where {$_ -ne ""}) | Select-Object -Index 6

            $End_Check = $Dirs_Copied + $Dirs_Failed + $Files_Copied + $Files_Failed

            if(($Dirs_Failed -ne "0") -or ($Files_Failed -ne "0")){
                Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 81 -Message '[File Sync:] File Failed to Copy, check log files.'
            }
            elseif(($Dirs_Copied -ne "0") -or ($Files_Copied -ne "0")){
                Write-Eventlog -LogName Application -Source $Event_Type -EntryType Warning -EventID 84 -Message '[File Sync:] Files have been copied over, the Website has been changed.'
            }
            elseif($End_Check -eq "0000"){
                Write-Eventlog -LogName Application -Source $Event_Type_LP -EntryType Information -EventID 87 -Message '[FileSync]: FileSync detects no change between webservers.'
            }
            else{
                $End_Check
				Write-Eventlog -LogName Application -Source $Event_Type_LP -EntryType Information -EventID 91 -Message '[FileSync]: An Unknown Error occured, check log files.'
            }

            Write-Eventlog -LogName Application -Source $Event_Type_LP -EntryType Information -EventID 94 -Message (  "[FileSync]: File Sync Completed:" + "`n" + `
                            "$Header" + "`n" + `
                            "$Dirs" + "`n" + `
                            "$Files" + "`n" + `
                            "$Bytes" + "`n" + `
                            "$Times" + "`n" + "`n" + `
                            "$End_Time")
	}

	catch [Exception] {
		Write-Eventlog -LogName Application -Source $Event_Type_LP -EntryType Error -EventID 82 -Message ('[Log_parse]: ' + $_)
		Exit
	}
}

Try {
    Copy_Files $Event_Type $LOG_PATH $Source $Rocky_I
    Copy_Files $Event_Type $LOG_PATH $Source $Rocky_II
}

Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[FileSync] $_'
	Exit
}
