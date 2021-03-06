#Add-PSSnapin VMware.VimAutomation.Core

$vSphere = "Domino.invest.com"
$User = "invest\vmadmin"
$Password = "I like virtual."

Connect-VIServer -Server $vSphere -User $User -Password $Password

Get-VM |
Select Name,
PowerState,
@{N="OS";E={$_.Guest.OSFullName}},
@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}},
@{N="Folder";E={$_.Folder.Name}} | Export-csv "C:\Users\lcorbo\Downloads\VM_report-Domino.csv" -notype
