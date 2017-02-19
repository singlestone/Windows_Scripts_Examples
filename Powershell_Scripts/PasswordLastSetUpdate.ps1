# Add the QUEST Active Roles AD Managements tools.
Add-PSSnapin Quest.ActiveRoles.ADManagement
Set-QADPSSnapinSettings -DefaultSizeLimit 0

# Variable for path, change to convenient location
# FORMER $exportPath = "C:\Windows\ADMT\_Option & Include Files\Users\PasswordLastSetUserstoChange.txt"
$exportPath = "C:\WindowsPowerShell\Modules\SIDHistory\SIDHistory\sid-users.txt"

# Read the text file, load an AD user for each line, and change their setting
Get-Content $exportPath | Get-QADUser | Set-QADUser -UserMustChangePassword $false