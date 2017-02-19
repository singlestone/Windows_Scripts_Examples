##################################
## VPN_Token_Report.ps1		    ##
## 8/20/2014                    ##
## By Louie Corbo               ##
##################################


####################
## Import Modules ##
####################

import-module ActiveDirectory

###############
## Set Paths ##
###############

$OUTPUTFILEPATH = "$PSScriptRoot\Token_Report$(get-date -f MM_dd_yyyy_HH_mm_ss).csv"

#######################
## Create Data Table ##
#######################

# Queries AD for a list of all users with a non-null "vasco-LinkUserToDPToken" attribute.
$VPN_USERS = Get-ADUser -Filter {vasco-LinkUserToDPToken -like '*'}  -SearchBase 'OU=CarMaxUsers,DC=DMX,DC=LOCAL' -Properties vasco-LinkUserToDPToken | select Name, SamAccountName, @{n="vasco-LinkUserToDPToken";e={[string]$_.'vasco-LinkUserToDPToken'}}, DistinguishedName 

#initializes the data table
$TOKEN_REPORT = @()

$tabName = "Token Report"

#Create Table object
$table = New-Object system.Data.DataTable “$tabName”

#Define Columns
$col1 = New-Object system.Data.DataColumn 'Name',([string])
$col2 = New-Object system.Data.DataColumn 'SamAccountName',([string])
$col3 = New-Object system.Data.DataColumn 'Token_ID',([string])
$col4 = New-Object system.Data.DataColumn 'Token_DN',([string])
$col5 = New-Object system.Data.DataColumn 'USER_DN',([string])
$col6 = New-Object system.Data.DataColumn 'OU_Check',([string])
$col7 = New-Object system.Data.DataColumn 'Token_Count',([string])

#Add the Columns
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)
$table.columns.add($col6)
$table.columns.add($col7)

#Looping through each user individually.
foreach($VPN_USER in $VPN_USERS){
		$Name = $VPN_USER.Name
	$SamAccountName = $VPN_USER.SamAccountName
	$vasco_LinkUserToDPToken = $VPN_USER.'vasco-LinkUserToDPToken'
	$DistinguishedName = $VPN_USER.DistinguishedName

	#The attribute "vasco-LinkUserToDPToken" separates multiple tokens in the attribute by using the " ", character.  So now we split them up and load them in to the "Whole_Token" object
	$Whole_Token = $vasco_LinkUserToDPToken.split(" ")
	
	#This counts the number of tokens assigned to account currently loaded in $VPN_USER
	$Token_Count = ([regex]::Matches($vasco_LinkUserToDPToken,"CN=")).count
	
	

	#This loops through each Token individually. 
	foreach($Token_Piece in $Whole_Token){
	
		#Create a row
		$row = $table.NewRow()
		$DistinguishedName_check = $DistinguishedName.split(",",2)
		$Token_Piece_check = $Token_Piece.split(",",2)

		#This is used to separate out the Token ID from the Token's distinguished name, putting it in it's own column.
		$Token_ID = $Token_Piece.split(",")[0].Trim("CN=")

		#This logic is used to determine if the Token is in the same OU as the assigned user.
		if($DistinguishedName_check[1] -eq $Token_Piece_check[1]){$OU_Check = "True"}
		
		#However it doesn't mark the test as failed if the user in question is in the "LegalHold" or DisabledUsers" OU since they aren't in use anyway.
		elseIf($DistinguishedName -match "OU=LegalHold,OU=CarMaxUsers,DC=DMX,DC=LOCAL"){$OU_Check = "True"}
		elseIf($DistinguishedName -match "OU=DisabledUsers,OU=CarMaxUsers,DC=DMX,DC=LOCAL"){$OU_Check = "True"}
		else{$OU_Check = "False"}

		#Enter data in the row
		$row.'Name' = $Name 
		$row.'SamAccountName' = $SamAccountName 
		$row.'Token_DN' = $Token_Piece
		$row.'Token_ID' = $Token_ID
		$row.'USER_DN' = $DistinguishedName
		$row.'OU_Check' = $OU_Check
		$row.'Token_Count' = $Token_Count

		#Add the row to the table
		$table.Rows.Add($row)
	}
}

#Once everything is organized as desired in the Data Table it's out
$tabCsv = $table | export-csv $OUTPUTFILEPATH -noType

