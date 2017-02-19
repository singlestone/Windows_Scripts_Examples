
Get-ADComputer -Filter * -properties * | Select CN, IPv4Address, LastLogonDate | Export-Csv "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\Output CSVs\Computers_IP.csv" -notype



$Instance = "localhost\SQLEXPRESS"
$Test = invoke-sqlcmd -InputFile "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\SQL Scripts\test.sql" -ServerInstance "localhost\SQLEXPRESS" 

$Test | Export-Csv "C:\Users\lcorbo\Desktop\test.csv" -notype


