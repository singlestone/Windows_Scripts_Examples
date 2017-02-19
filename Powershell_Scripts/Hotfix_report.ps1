
$Computername = "192.168.100.43"

$Last_Update = (`
    Get-HotFix -ComputerName $Computername `
    | Select InstalledOn `
    | Sort-Object InstalledOn -Descending `
    | Select InstalledOn -First 1 `
    ).installedOn

$Last_Update.ToString("MM-dd-yyyy")