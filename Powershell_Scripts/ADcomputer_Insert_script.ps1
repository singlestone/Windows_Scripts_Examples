# ADcomputer_Insert_script
# By Louie Corbo
# 12/5/2014

# This Script assumes "Import-Module sqlps –DisableNameChecking" has been run on the powershell instance.  
# Currently uisng local Sql-express

$Instance = "servername\SQLEXPRESS"

$DELETE_Query =	"Delete from inventory.dbo.ADcomputer
				GO"
invoke-sqlcmd -Query $DELETE_Query -ServerInstance $Instance

Get-ADComputer -Filter * -properties * | ForEach-Object { 
	$INSERT_AccountExpirationDate = $_.AccountExpirationDate
	$INSERT_accountExpires = $_.accountExpires
	$INSERT_AccountLockoutTime = $_.AccountLockoutTime
	$INSERT_AccountNotDelegated = $_.AccountNotDelegated
	$INSERT_AllowReversiblePasswordEncryption = $_.AllowReversiblePasswordEncryption
	$INSERT_BadLogonCount = $_.BadLogonCount
	$INSERT_CannotChangePassword = $_.CannotChangePassword
	$INSERT_CanonicalName = $_.CanonicalName
	$INSERT_Certificates = $_.Certificates
	$INSERT_CN = $_.CN
	$INSERT_codePage = $_.codePage
	$INSERT_countryCode = $_.countryCode
	$INSERT_Created = $_.Created
	$INSERT_createTimeStamp = $_.createTimeStamp
	$INSERT_DeletedDescription = $_.DeletedDescription
	$INSERT_DisplayName = $_.DisplayName
	$INSERT_DistinguishedName = $_.DistinguishedName
	$INSERT_DNSHostName = $_.DNSHostName
	$INSERT_DoesNotRequirePreAuth = $_.DoesNotRequirePreAuth
	$INSERT_dSCorePropagationData = $_.dSCorePropagationData
	$INSERT_Enabled = $_.Enabled
	$INSERT_HomedirRequired = $_.HomedirRequired
	$INSERT_HomePage = $_.HomePage
	$INSERT_instanceType = $_.instanceType
	$INSERT_IPv4Address = $_.IPv4Address
	$INSERT_IPv6Address = $_.IPv6Address
	$INSERT_isCriticalSystemObject = $_.isCriticalSystemObject
	$INSERT_isDeleted = $_.isDeleted
	$INSERT_LastBadPasswordAttempt = $_.LastBadPasswordAttempt
	$INSERT_LastKnownParent = $_.LastKnownParent
	$INSERT_lastLogon = $_.lastLogon
	$INSERT_LastLogonDate = $_.LastLogonDate
	$INSERT_lastLogonTimestamp = $_.lastLogonTimestamp
	$INSERT_localPolicyFlags = $_.localPolicyFlags
	$INSERT_Location = $_.Location
	$INSERT_LockedOut = $_.LockedOut
	$INSERT_logonCount = $_.logonCount
	$INSERT_ManagedBy = $_.ManagedBy
	$INSERT_MemberOf = $_.MemberOf
	$INSERT_MNSLogonAccount = $_.MNSLogonAccount
	$INSERT_Modified = $_.Modified
	$INSERT_modifyTimeStamp = $_.modifyTimeStamp
	$INSERT_Name = $_.Name
	$INSERT_NamenTSecurityDescriptor = $_.NamenTSecurityDescriptor
	$INSERT_ObjectCategory = $_.ObjectCategory
	$INSERT_ObjectClass = $_.ObjectClass
	$INSERT_ObjectGUID = $_.ObjectGUID
	$INSERT_objectSid = $_.objectSid
	$INSERT_OperatingSystem = $_.OperatingSystem
	$INSERT_OperatingSystemHotfix = $_.OperatingSystemHotfix
	$INSERT_OperatingSystemServicePack = $_.OperatingSystemServicePack
	$INSERT_OperatingSystemVersion = $_.OperatingSystemVersion
	$INSERT_PasswordExpired = $_.PasswordExpired
	$INSERT_PasswordLastSet = $_.PasswordLastSet
	$INSERT_PasswordNeverExpires = $_.PasswordNeverExpires
	$INSERT_PasswordNotRequired = $_.PasswordNotRequired
	$INSERT_PrimaryGroup = $_.PrimaryGroup
	$INSERT_primaryGroupID = $_.primaryGroupID
	$INSERT_ProtectedFromAccidentalDeletion = $_.ProtectedFromAccidentalDeletion
	$INSERT_pwdLastSet = $_.pwdLastSet
	$INSERT_SamAccountName = $_.SamAccountName
	$INSERT_sAMAccountType = $_.sAMAccountType
	$INSERT_sDRightsEffective = $_.sDRightsEffective
	$INSERT_ServiceAccount = $_.ServiceAccount
	$INSERT_servicePrincipalName = $_.servicePrincipalName
	$INSERT_ServicePrincipalNames = $_.ServicePrincipalNames
	$INSERT_SID = $_.SID
	$INSERT_SIDHistory = $_.SIDHistory
	$INSERT_TrustedForDelegation = $_.TrustedForDelegation
	$INSERT_TrustedToAuthForDelegation = $_.TrustedToAuthForDelegation
	$INSERT_UseDESKeyOnly = $_.UseDESKeyOnly
	$INSERT_userAccountControl = $_.userAccountControl
	$INSERT_userCertificate = $_.userCertificate
	$INSERT_UserPrincipalName = $_.UserPrincipalName
	$INSERT_uSNChanged = $_.uSNChanged
	$INSERT_uSNCreated = $_.uSNCreated
	$INSERT_whenChanged = $_.whenChanged
	$INSERT_whenCreated = $_.whenCreated

$INSERT_Query = "
			INSERT INTO inventory.dbo.ADcomputer 
					   (AccountExpirationDate,
						accountExpires,
						AccountLockoutTime,
						AccountNotDelegated,
						AllowReversiblePasswordEncryption,
						BadLogonCount,
						CannotChangePassword,
						CanonicalName,
						Certificates,
						CN,
						codePage,
						countryCode,
						Created,
						createTimeStamp,
						Deleted,
						DisplayName,
						DistinguishedName,
						DNSHostName,
						DoesNotRequirePreAuth,
						dSCorePropagationData,
						Enabled,
						HomedirRequired,
						HomePage,
						instanceType,
						IPv4Address,
						IPv6Address,
						isCriticalSystemObject,
						isDeleted,
						LastBadPasswordAttempt,
						LastKnownParent,
						lastLogon,
						LastLogonDate,
						lastLogonTimestamp,
						localPolicyFlags,
						Location,
						LockedOut,
						logonCount,
						ManagedBy,
						MemberOf,
						MNSLogonAccount,
						Modified,
						modifyTimeStamp,
						Name,
						nTSecurityDescriptor,
						ObjectCategory,
						ObjectClass,
						ObjectGUID,
						objectSid,
						OperatingSystem,
						OperatingSystemHotfix,
						OperatingSystemServicePack,
						OperatingSystemVersion,
						PasswordExpired,
						PasswordLastSet,
						PasswordNeverExpires,
						PasswordNotRequired,
						PrimaryGroup,
						primaryGroupID,
						ProtectedFromAccidentalDeletion,
						pwdLastSet,
						SamAccountName,
						sAMAccountType,
						sDRightsEffective,
						ServiceAccount,
						servicePrincipalName,
						ServicePrincipalNames,
						SID,
						SIDHistory,
						TrustedForDelegation,
						TrustedToAuthForDelegation,
						UseDESKeyOnly,
						userAccountControl,
						userCertificate,
						UserPrincipalName,
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
						$INSERT_Certificates ','
						$INSERT_CN ','
						$INSERT_codePage ','
						$INSERT_countryCode ','
						$INSERT_Created ','
						$INSERT_createTimeStamp ','
						$INSERT_DeletedDescription ','
						$INSERT_DisplayName ','
						$INSERT_DistinguishedName ','
						$INSERT_DNSHostName ','
						$INSERT_DoesNotRequirePreAuth ','
						$INSERT_dSCorePropagationData ','
						$INSERT_Enabled ','
						$INSERT_HomedirRequired ','
						$INSERT_HomePage ','
						$INSERT_instanceType ','
						$INSERT_IPv4Address ','
						$INSERT_IPv6Address ','
						$INSERT_isCriticalSystemObject ','
						$INSERT_isDeleted ','
						$INSERT_LastBadPasswordAttempt ','
						$INSERT_LastKnownParent ','
						$INSERT_lastLogon ','
						$INSERT_LastLogonDate ','
						$INSERT_lastLogonTimestamp ','
						$INSERT_localPolicyFlags ','
						$INSERT_Location ','
						$INSERT_LockedOut ','
						$INSERT_logonCount ','
						$INSERT_ManagedBy ','
						$INSERT_MemberOf ','
						$INSERT_MNSLogonAccount ','
						$INSERT_Modified ','
						$INSERT_modifyTimeStamp ','
						$INSERT_Name ','
						$INSERT_NamenTSecurityDescriptor ','
						$INSERT_ObjectCategory ','
						$INSERT_ObjectClass ','
						$INSERT_ObjectGUID ','
						$INSERT_objectSid ','
						$INSERT_OperatingSystem ','
						$INSERT_OperatingSystemHotfix ','
						$INSERT_OperatingSystemServicePack ','
						$INSERT_OperatingSystemVersion ','
						$INSERT_PasswordExpired ','
						$INSERT_PasswordLastSet ','
						$INSERT_PasswordNeverExpires ','
						$INSERT_PasswordNotRequired ','
						$INSERT_PrimaryGroup ','
						$INSERT_primaryGroupID ','
						$INSERT_ProtectedFromAccidentalDeletion ','
						$INSERT_pwdLastSet ','
						$INSERT_SamAccountName ','
						$INSERT_sAMAccountType ','
						$INSERT_sDRightsEffective ','
						$INSERT_ServiceAccount ','
						$INSERT_servicePrincipalName ','
						$INSERT_ServicePrincipalNames ','
						$INSERT_SID ','
						$INSERT_SIDHistory ','
						$INSERT_TrustedForDelegation ','
						$INSERT_TrustedToAuthForDelegation ','
						$INSERT_UseDESKeyOnly ','
						$INSERT_userAccountControl ','
						$INSERT_userCertificate ','
						$INSERT_UserPrincipalName ','
						$INSERT_uSNChanged ','
						$INSERT_uSNCreated ','
						$INSERT_whenChanged ','
						$INSERT_whenCreated');"
						
	invoke-sqlcmd -Query $INSERT_Query -ServerInstance $Instance
	}

