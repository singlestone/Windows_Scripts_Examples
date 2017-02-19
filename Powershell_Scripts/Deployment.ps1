<#-----------------------------------------------------------------------------------------------------------------
Script   	: Deployment.ps1 
Author   	: Louie Corbo
Date     	: 01/04/15
Keywords 	: FileSync, ROBOCOPY, Drupal, Zip Archive
Comments 	: Copies files from Staging into production, and makes an archived copy and log of the change.
------------------------------------------------------------------------------------------------------------------#>   

# Set current date for logging.
$Date = get-date -Format yyyyMMddhhmmss

# Step 1: Start Logfile of production change.
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path $LOG_PATH -append

#####################################
$Source = 'e:\wwwroot'
$Production =  '\\wwwroot'
$LOG_PATH = "e:\archive\logs\Deployment_$Date"
$Event_Type = 'Site Deployment'
$Source = "e:\wwwroot"
$Release =  "e:\release\wwwroot"
$Archive = "e:\archive\previous_states\release_backup_$Date"

#####################################

Try {
	If (!([System.Diagnostics.EventLog]::SourceExists('Drupal Site Deployment')))	{
		New-EventLog -LogName Application -Source $Event_Type
	}

	# Set Alias for 7-zip
	if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {
		Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Dependency] $env:ProgramFiles\7-Zip\7z.exe needed'
		Stop-Transcript
		Exit
	}
	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message '[Step 1] Completed $Date'
	# End of Prep Event Source
} 
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Step 1] $_'
	Stop-Transcript
	Exit
}

# Step 2: Confirm release environment is the same as production environment
Try {
	$result = ROBOCOPY $Source $Rocky_III /e /l /ns /njs /njh /ndl /fp /log:reconcile.txt
	if($result -ne ""){
		write-host "Release and Production's not the same, process aborted!"
		Stop-Transcript
		Exit
		}
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message '[Step 2] Completed $Date'
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Step 2] $_'
	Stop-Transcript
	Exit
}

# Step 3: Create zip archive of staging environment
Try {
	sz a -mx=9 $Archive $Source
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message '[Step 3] Completed $Date'
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Step 3] $_'
	Stop-Transcript
	Exit
}

# Step 4: Mirror Staging Environment into production
Try {
	ROBOCOPY $Source $Production /mir /fft 
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message '[Step 4] Completed $Date'
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Step 4] $_'
	Stop-Transcript
	Exit
}

# Step 5: Mirror Staging Environment into release
Try {
	ROBOCOPY $Source $Release /mir /fft 
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message '[Step 5] Completed $Date'
}
Catch [Exception] {
	Write-Eventlog -LogName Application -Source $Event_Type -EntryType Error -EventID 54 -Message '[Step 5] $_'
	Stop-Transcript
	Exit
}
Write-Eventlog -LogName Application -Source $Event_Type -EntryType Information -EventID 54 -Message 'Drupal Site Deployment completed with no know issues. $Date'
Stop-Transcript
Exit