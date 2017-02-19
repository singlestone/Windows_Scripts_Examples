
#Files and Directories Used

$currentScriptDirectory = Get-Location
$EventlgFunc = ".\Script_Modules\Eventlog_Functions.psm1"
$SrvrSpcFunc = ".\Script_Modules\ServerSpec_Functions.psm1"
$ENV:EventlgFunc = "$currentScriptDirectory\Script_Modules\Eventlog_Functions.psm1"
$ENV:SrvrSpcFunc = "$currentScriptDirectory\Script_Modules\ServerSpec_Functions.psm1"
$ResultsDir =  "$currentScriptDirectory\Results\"
$file =        ".\ServerList\ServerList.txt"
$dot_rspec =   ".\ServerSpec\.rspec"
$Rakefile =    ".\ServerSpec\Rakefile"
$specfile =    ".\ServerSpec\spec\allservers\patch_spec.rb"
$spechelper =  ".\ServerSpec\spec\patch_spec_helper.rb"
$AppName = "ServerSpecScan"
$async = $true
$debug = $false
	
If (!([System.Diagnostics.EventLog]::SourceExists($AppName)))    {
        New-EventLog -LogName Application -Source $AppName
    }

Function SanityCheck {

	Param(
		[Parameter(Mandatory=$true)]$Path
	)

	If (!(Test-Path -path $Path))
	{
		$Message = "$Path not found, exiting...."
		Write-Eventlog -LogName Application -Source $AppName -EntryType Error -EventID 404 -Message $Message
		Write-Host $Message
		EXIT
	}
}	

SanityCheck $EventlgFunc
SanityCheck $SrvrSpcFunc
SanityCheck $currentScriptDirectory
SanityCheck $file
SanityCheck $dot_rspec
SanityCheck $Rakefile
SanityCheck $specfile
SanityCheck $spechelper

$init =  {
	Import-Module -force $ENV:EventlgFunc
	Import-Module -force $ENV:SrvrSpcFunc
}

$Runlist = Get-Content $file

#Event Log name


$scriptBlock_Eventlg = {
    Param(
		$ResultsDir ,
		$Server,
		$currentScriptDirectory
    )

	Set-EventlogResults $ResultsDir $Server
}

$scriptBlock_SrvrSpc = {
    Param(
		$ResultsDir ,
		$Server,
		$currentScriptDirectory
    )

	Set-ServerSpecResults $Server $currentScriptDirectory
}

Function Invoke-AsyncRunlist {
	foreach ($Server in $Runlist)	{
		if ($async) {
			$job = Start-Job `
				-ScriptBlock $scriptBlock_Eventlg `
				-InitializationScript $init `
				-Name "Runs a status check on $server." `
				-ArgumentList @(
					$ResultsDir ,
					$Server,
					$currentScriptDirectory) -Debug:$debug
		} else {
			Import-Module -force $ENV:EventlgFunc
			Set-EventlogResults $ResultsDir $Server
		}
	}
	
	foreach ($Server in $Runlist)	{
		if ($async) {
			$job = Start-Job `
				-ScriptBlock $scriptBlock_SrvrSpc `
				-InitializationScript $init `
				-Name "Runs a status check on $server." `
				-ArgumentList @(
					$ResultsDir ,
					$Server,
					$currentScriptDirectory) -Debug:$debug
		} else {
			Import-Module -force $ENV:SrvrSpcFunc
			Set-ServerSpecResults $Server $currentScriptDirectory
		}
	}
	if ($async) {
		$jobs = get-job
		$jobs | Wait-Job | Receive-Job
		$jobs | foreach {
			$job = $_
			write-host "$($job.Id) - $($job.Name) - $($job.State)"
		}
		$jobs | remove-job
	}
}

Invoke-AsyncRunlist
