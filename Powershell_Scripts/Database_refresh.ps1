# ADcomputer_Insert_script
# By Louie Corbo
# 12/9/2014

# Currently using local Sql-express

Import-Module sqlps –DisableNameChecking

$Instance = " localhost\SQLEXPRESS"

$Drop_DB_Query = "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\SQL Scripts\Drop_Inventory_Database.sql"
$Create_DB_Query = "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\SQL Scripts\Inventory_DB_Creation.sql"
$ADComputer_DT_Creation_Query =	"C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\SQL Scripts\ADcomputer_Table_Creation.sql"
$ADUser_DT_Creation_Query =	"C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\SQL Scripts\ADUser_Table_Creation.sql"

invoke-sqlcmd -InputFile $Drop_DB_Query -ServerInstance $Instance
invoke-sqlcmd -InputFile $Create_DB_Query -ServerInstance $Instance
invoke-sqlcmd -InputFile $ADComputer_DT_Creation_Query -ServerInstance $Instance
invoke-sqlcmd -InputFile $ADUser_DT_Creation_Query -ServerInstance $Instance

& "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\PowerShell Scripts\ADcomputer_Insert_script.ps1"
& "C:\Users\lcorbo\Desktop\My Documents\Project\Inventory Script\PowerShell Scripts\ADUser_Insert_script.ps1"