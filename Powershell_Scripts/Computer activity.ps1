import-module ActiveDirectory
$Servers = Get-ADComputer -filter * -SearchBase "ou=servers,dc=invest,dc=com" -properties IPv4Address | Select Name, IPv4Address

#-filter {Name -eq 'Heimdall'}

$Server_List = Foreach( $Server in $Servers)
{
    $Output = $Server.Name
    If (Test-Connection -comp $Output -count 2 -quiet)
        {$Status = "Online"}
    Else 
        {$Status = "Offline"}
        New-Object PSCustomObject -Property @{ 
        Name = $Server.Name
        Address = $Server.IPv4Address
        Status = $Status
    }
}

$Server_List | Format-Table
$Server_List | Export-Csv C:\Users\lcorbo\Downloads\ServerStatusList.csv -notype