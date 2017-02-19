##################################
## Update_Linux_Attributes      ##
## 5/20/2014                    ##
## By Louie Corbo               ##
##################################

## Creates User attributes for Linux Users based on already existing attributes




## This section assumes the script is being run inside the DMX domain and connects to the FAKECORP forest, user will be prompted to login. If login is regected the script should fail assumes
## as all look ups are using the FAKECORP searchbase.
import-module ActiveDirectory
New-PSDrive -Name FAKECORP -PSProvider ActiveDirectory -Server "DCCORP07.FAKECORP.adcmax.acme.org" -Scope Global -credential (Get-Credential "FAKECORP\#lcorbo") -root "//RootDSE/"
cd FAKECORP:


$OUTPUTFILEPATH1 = "C:\AdminFiles\Scripts\AD Scripting\Update_Linux_Attributes_log1"
$OUTPUTFILEPATH2 = "C:\AdminFiles\Scripts\AD Scripting\Update_Linux_Attributes_log2"

if (Test-Path $OUTPUTFILEPATH1){
	Remove-Item $OUTPUTFILEPATH1
}

if (Test-Path $OUTPUTFILEPATH2){
	Remove-Item $OUTPUTFILEPATH2
}

## This function takes the username, older attribute and new attribute name, creates or updates the new attribute name or replaces it with the value of the  old attribute.
## If the old attribute doesn't exist for user, the script just skips this part.
function ATTRIBUTES_UPDATE($user_name, $old_attribute, $new_attribute_name){
	$TEMP = Get-ADUser $user_name -Properties *
	
	if($TEMP.$old_attribute){
		## If the attribute already exists it needs to be replaced, otherwise it needs to be added, the action must be explictely stated or else it will fail.
		if ($TEMP.$new_attribute_name) {
			SET-ADUSER $user_name -replace @{$new_attribute_name=$TEMP.$old_attribute}
		}
		else {
			SET-ADUSER $user_name -add @{$new_attribute_name=$TEMP.$old_attribute}
		}
		$NewLine = "$user_name updated $new_attribute_name with $TEMP.$old_attribute"
		$NewLine | add-content -path $OUTPUTFILEPATH1
	}
	else{
		$NewLine = "$user_name does not have attribute $old_attribute."
		$NewLine | add-content -path $OUTPUTFILEPATH1
	}
}

$IDLIST = Import-Csv -path "C:\AdminFiles\Scripts\AD Scripting\linuxusers2.csv"
foreach($UID in $IDLIST){
	$DMX=$UID.DMX
	$FAKECORP=$UID.FAKECORP
	ATTRIBUTES_UPDATE $FAKECORP "msSFU30Gecos" "Gecos"
	ATTRIBUTES_UPDATE $FAKECORP "msSFU30GidNumber" "GidNumber"
	ATTRIBUTES_UPDATE $FAKECORP "msSFU30HomeDirectory" "unixHomeDirectory"
	ATTRIBUTES_UPDATE $FAKECORP "msSFU30LoginShell" "LoginShell"
	ATTRIBUTES_UPDATE $FAKECORP "msSFU30UidNumber" "UidNumber"
	if ($FAKECORP.UID) {
		SET-ADUSER $FAKECORP -replace @{"UID"=$DMX}
	}
	else {
		SET-ADUSER $FAKECORP -add @{"UID"=$DMX}
	}
	$NewLine = "$FAKECORP updated to included UID $DMX"
	$NewLine | add-content -path $OUTPUTFILEPATH2
}

