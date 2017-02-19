function Get-DateDiff { 
param ( 
    [CmdletBinding()] 
    
    [parameter(Mandatory=$true)] 
    [datetime]$date1, 
    
    [parameter(Mandatory=$true)] 
    [datetime]$date2 
)  
    
    if ($date2 -gt $date1){$diff = $date2 - $date1} 
    else {$diff = $date1 - $date2} 
    $diff
   
}
try {
  $objSession = New-Object -com "Microsoft.Update.Session"
  $objSearcher= $objSession.CreateUpdateSearcher()
  $colHistory = $objSearcher.QueryHistory(1, 1)
  }
catch 
  {
  Write-Host "ERROR: $($Error[0])";
  exit 1;
  }
Foreach($objEntry in $colHistory)
  {
  $mes = $objEntry.Title
  $d = $objEntry.Date
  }
$date1 = get-date -uformat "%Y.%m.%d"
$t = $d.tostring("yyyy.MM.dd").split(" ")
$date2 = $t[0]
try {
  $stat = Get-DateDiff $date1 $date2
  }
catch 
  {
  Write-Host "ERROR: $($Error[0])";
  exit 1;
  }
$res = $stat.tostring().split(".")
if ($res -eq "00.00.00")
{
Write-Host "Message: Last installed update:" $mes
Write-Host "Statistic:" 0
exit 0
}
Write-Host "Message: Last installed update:" $mes
Write-Host "Statistic:" $res[0]
exit 0