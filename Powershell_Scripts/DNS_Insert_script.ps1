# ADcomputer_Insert_script
# By Louie Corbo
# 12/5/2014

# This Script assumes "Import-Module sqlps –DisableNameChecking" has been run on the powershell instance.  
# Currently uisng local Sql-express


$Instance = "localhost\SQLEXPRESS"

$DELETE_Query =	"Delete from inventory.dbo.ADuser
				GO"
invoke-sqlcmd -Query $DELETE_Query -ServerInstance $Instance

Get-ADUser -Filter * -properties * | ForEach-Object { 
	$INSERT_AccountExpirationDate = $_.AccountExpirationDate
	$INSERT_accountExpires = $_.accountExpires
	$INSERT_AccountLockoutTime = $_.AccountLockoutTime
	$INSERT_AccountNotDelegated = $_.AccountNotDelegated
	$INSERT_AllowReversiblePasswordEncryption = $_.AllowReversiblePasswordEncryption
	$INSERT_BadLogonCount = $_.BadLogonCount
	$INSERT_CannotChangePassword = $_.CannotChangePassword
	$INSERT_CanonicalName = $_.CanonicalName
	$INSERT_City = $_.City
	$INSERT_CN = $_.CN
	$INSERT_codePage = $_.codePage
	$INSERT_Company = $_.Company
	$INSERT_Country = $_.Country
	$INSERT_countryCode = $_.countryCode
	$INSERT_Created = $_.Created
	$INSERT_createTimeStamp = $_.createTimeStamp
	$INSERT_Deleted = $_.Deleted
	$INSERT_Department = $_.Department
	$INSERT_DisplayName = $_.DisplayName
	$INSERT_DistinguishedName = $_.DistinguishedName
	$INSERT_Division = $_.Division
	$INSERT_DoesNotRequirePreAuth = $_.DoesNotRequirePreAuth
	$INSERT_EmailAddress = $_.EmailAddress
	$INSERT_EmployeeID = $_.EmployeeID
	$INSERT_EmployeeNumber = $_.EmployeeNumber
	$INSERT_Enabled = $_.Enabled
	$INSERT_GivenName = $_.GivenName
	$INSERT_HomeDirectory = $_.HomeDirectory
	$INSERT_HomedirRequired = $_.HomedirRequired
	$INSERT_HomeDrive = $_.HomeDrive
	$INSERT_Initials = $_.Initials
	$INSERT_instanceType = $_.instanceType
	$INSERT_isDeleted = $_.isDeleted
	$INSERT_LastBadPasswordAttempt = $_.LastBadPasswordAttempt
	$INSERT_LastKnownParent = $_.LastKnownParent
	$INSERT_LastLogonDate = $_.LastLogonDate
	$INSERT_lastLogonTimestamp = $_.lastLogonTimestamp
	$INSERT_LockedOut = $_.LockedOut
	$INSERT_LogonWorkstations = $_.LogonWorkstations
	$INSERT_mail = $_.mail
	$INSERT_mailNickname = $_.mailNickname
	$INSERT_Manager = $_.Manager
	$INSERT_MNSLogonAccount = $_.MNSLogonAccount
	$INSERT_Modified = $_.Modified
	$INSERT_modifyTimeStamp = $_.modifyTimeStamp
	$INSERT_Name = $_.Name
	$INSERT_ObjectCategory = $_.ObjectCategory
	$INSERT_ObjectClass = $_.ObjectClass
	$INSERT_ObjectGUID = $_.ObjectGUID
	$INSERT_objectSid = $_.objectSid
	$INSERT_Office = $_.Office
	$INSERT_Organization = $_.Organization
	$INSERT_OtherName = $_.OtherName
	$INSERT_PasswordExpired = $_.PasswordExpired
	$INSERT_PasswordLastSet = $_.PasswordLastSet
	$INSERT_PasswordNeverExpires = $_.PasswordNeverExpires
	$INSERT_PasswordNotRequired = $_.PasswordNotRequired
	$INSERT_POBox = $_.POBox
	$INSERT_PostalCode = $_.PostalCode
	$INSERT_PrimaryGroup = $_.PrimaryGroup
	$INSERT_primaryGroupID = $_.primaryGroupID
	$INSERT_ProfilePath = $_.ProfilePath
	$INSERT_ProtectedFromAccidentalDeletion = $_.ProtectedFromAccidentalDeletion
	$INSERT_pwdLastSet = $_.pwdLastSet
	$INSERT_SamAccountName = $_.SamAccountName
	$INSERT_sAMAccountType = $_.sAMAccountType
	$INSERT_ScriptPath = $_.ScriptPath
	$INSERT_sDRightsEffective = $_.sDRightsEffective
	$INSERT_SID = $_.SID
	$INSERT_SIDHistory = $_.SIDHistory
	$INSERT_SmartcardLogonRequired = $_.SmartcardLogonRequired
	$INSERT_State = $_.State
	$INSERT_StreetAddress = $_.StreetAddress
	$INSERT_Surname = $_.Surname
	$INSERT_Title = $_.Title
	$INSERT_TrustedForDelegation = $_.TrustedForDelegation
	$INSERT_TrustedToAuthForDelegation = $_.TrustedToAuthForDelegation
	$INSERT_UseDESKeyOnly = $_.UseDESKeyOnly
	$INSERT_userAccountControl = $_.userAccountControl
	$INSERT_uSNChanged = $_.uSNChanged
	$INSERT_uSNCreated = $_.uSNCreated
	$INSERT_whenChanged = $_.whenChanged
	$INSERT_whenCreated = $_.whenCreated

$INSERT_Query = "
					INSERT INTO inventory.dbo.ADUser
					   (AccountExpirationDate,					   
						accountExpires,
						AccountLockoutTime,
						AccountNotDelegated,
						AllowReversiblePasswordEncryption,
						BadLogonCount,
						CannotChangePassword,
						CanonicalName,
						City,
						CN,
						codePage,
						Company,
						Country,
						countryCode,
						Created,
						createTimeStamp,
						Deleted,
						Department,
						DisplayName,
						DistinguishedName,
						Division,
						DoesNotRequirePreAuth,
						EmailAddress,
						EmployeeID,
						EmployeeNumber,
						Enabled,
						GivenName,
						HomeDirectory,
						HomedirRequired,
						HomeDrive,
						Initials,
						instanceType,
						isDeleted,
						LastBadPasswordAttempt,
						LastKnownParent,
						LastLogonDate,
						lastLogonTimestamp,
						LockedOut,
						LogonWorkstations,
						mail,
						mailNickname,
						Manager,
						MNSLogonAccount,
						Modified,
						modifyTimeStamp,
						Name,
						ObjectCategory,
						ObjectClass,
						ObjectGUID,
						objectSid,
						Office,
						Organization,
						OtherName,
						PasswordExpired,
						PasswordLastSet,
						PasswordNeverExpires,
						PasswordNotRequired,
						POBox,
						PostalCode,
						PrimaryGroup,
						primaryGroupID,
						ProfilePath,
						ProtectedFromAccidentalDeletion,
						pwdLastSet,
						SamAccountName,
						sAMAccountType,
						ScriptPath,
						sDRightsEffective,
						SID,
						SIDHistory,
						SmartcardLogonRequired,
						State,
						StreetAddress,
						Surname,
						Title,
						TrustedForDelegation,
						TrustedToAuthForDelegation,
						UseDESKeyOnly,
						userAccountcontrol,
						uSNChanged,
						uSNCreated,
						whenChanged,
						whenCreated) 
 					Values 					
						('$INSERT_AccountExpirationDate ','
						  $INSERT_accountExpires ','
						  $INSERT_AccountLockoutTime ','
						  $INSERT_AccountNotDelegated ','
						  $INSERT_AllowReversiblePasswordEncryption ','
						  $INSERT_BadLogonCount ','
						  $INSERT_CannotChangePassword ','
						  $INSERT_CanonicalName ','
						  $INSERT_City ','
						  $INSERT_CN ','
						  $INSERT_codePage ','
						  $INSERT_Company ','
						  $INSERT_Country ','
						  $INSERT_countryCode ','
						  $INSERT_Created ','
						  $INSERT_createTimeStamp ','
						  $INSERT_Deleted ','
						  $INSERT_Department ','
						  $INSERT_DisplayName ','
						  $INSERT_DistinguishedName ','
						  $INSERT_Division ','
						  $INSERT_DoesNotRequirePreAuth ','
						  $INSERT_EmailAddress ','
						  $INSERT_EmployeeID ','
						  $INSERT_EmployeeNumber ','
						  $INSERT_Enabled ','
						  $INSERT_GivenName ','
						  $INSERT_HomeDirectory ','
						  $INSERT_HomedirRequired ','
						  $INSERT_HomeDrive ','
						  $INSERT_Initials ','
						  $INSERT_instanceType ','
						  $INSERT_isDeleted ','
						  $INSERT_LastBadPasswordAttempt ','
						  $INSERT_LastKnownParent ','
						  $INSERT_LastLogonDate ','
						  $INSERT_lastLogonTimestamp ','
						  $INSERT_LockedOut ','
						  $INSERT_LogonWorkstations ','
						  $INSERT_mail ','
						  $INSERT_mailNickname ','
						  $INSERT_Manager ','
						  $INSERT_MNSLogonAccount ','
						  $INSERT_Modified ','
						  $INSERT_modifyTimeStamp ','
						  $INSERT_Name ','
						  $INSERT_ObjectCategory ','
						  $INSERT_ObjectClass ','
						  $INSERT_ObjectGUID ','
						  $INSERT_objectSid ','
						  $INSERT_Office ','
						  $INSERT_Organization ','
						  $INSERT_OtherName ','
						  $INSERT_PasswordExpired ','
						  $INSERT_PasswordLastSet ','
						  $INSERT_PasswordNeverExpires ','
						  $INSERT_PasswordNotRequired ','
						  $INSERT_POBox ','
						  $INSERT_PostalCode ','
						  $INSERT_PrimaryGroup ','
						  $INSERT_primaryGroupID ','
						  $INSERT_ProfilePath ','
						  $INSERT_ProtectedFromAccidentalDeletion ','
						  $INSERT_pwdLastSet ','
						  $INSERT_SamAccountName ','
						  $INSERT_sAMAccountType ','
						  $INSERT_ScriptPath ','
						  $INSERT_sDRightsEffective ','
						  $INSERT_SID ','
						  $INSERT_SIDHistory ','
						  $INSERT_SmartcardLogonRequired ','
						  $INSERT_State ','
						  $INSERT_StreetAddress ','
						  $INSERT_Surname ','
						  $INSERT_Title ','
						  $INSERT_TrustedForDelegation ','
						  $INSERT_TrustedToAuthForDelegation ','
						  $INSERT_UseDESKeyOnly ','
						  $INSERT_userAccountcontrol ','
						  $INSERT_uSNChanged ','
						  $INSERT_uSNCreated ','
						  $INSERT_whenChanged ','
						  $INSERT_whenCreated			
						');"
	invoke-sqlcmd -Query $INSERT_Query -ServerInstance $Instance
	}
