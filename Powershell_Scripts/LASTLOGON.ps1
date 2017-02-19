##################################
## Update_Linux_userList   		##
## 5/22/2014                    ##
## By Louie Corbo               ##
##################################

$IMPORTEDCSV = Import-Csv -path ".\lists\arcsight.csv"
$OUTPUTFILEPATH1 = ".\lists\arcsight-updated.csv"
$NewLine = "{0},{1},{2},{3},{4}" -f "FAKECORP_ID", "Name", "Node", "KMX ID", "DN"
$NewLine | add-content -path $OUTPUTFILEPATH1

import-module ActiveDirectory
New-PSDrive -Name FAKECORP -PSProvider ActiveDirectory -Server "DCCORP07.FAKECORP.adcmax.carmax.org" -Scope Global -credential (Get-Credential "FAKECORP\#lcorbo") -root "//RootDSE/"
cd FAKECORP:

foreach($ROW in $IMPORTEDCSV){
	$USERINFO = Get-ADUser $ROW.CMAXCORP_ID -Properties distinguishedName, sAMAccountName
	$CMAXCORP_ID = $ROW.CMAXCORP_ID
	$Name = $ROW.Name
	$Node = $ROW.Node
	$sAMAccountName = $USERINFO.sAMAccountName
	$distinguishedName	= $USERINFO.distinguishedName
	
	cd L:
	$NewLine = "{0},{1},{2},{3},{4}" -f "$FAKECORP_ID", "$Name", "$Node", "$sAMAccountName", "$distinguishedName"
	#, "'$USERINFO.distinguishedName'"
	$NewLine | add-content -path $OUTPUTFILEPATH1
	cd FAKECORP:
}