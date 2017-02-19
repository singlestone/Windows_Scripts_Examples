INSERT INTO [inventory].[dbo].[TEST_IMPORT] ([Status], [Name]) Values 	(''$STATUS'', ''$NAME'');
/*INSERT INTO [inventory].[dbo].[TEST_IMPORT] ([Status], [Name]) Values 	('Status', 'Name'); */

/*Delete from inventory.dbo.ADcomputer
GO

INSERT INTO inventory.dbo.ADcomputer 

	(AccountNotDelegated, 
	 AllowReversiblePasswordEncryption, 
	 CannotChangePassword, 
	 DoesNotRequirePreAuth, 
	 Enabled, 
	 HomedirRequired, 
	 isCriticalSystemObject, 
	 MNSLogonAccount, 
	 PasswordExpired, 
	 PasswordNeverExpires, 
	 PasswordNotRequired, 
	 ProtectedFromAccidentalDeletion, 
	 TrustedForDelegation, 
	 TrustedToAuthForDelegation, 
	 UseDESKeyOnly) 
	 Values 
		(
			'$($ADcomputer.AccountNotDelegated)','
			 $($ADcomputer.AllowReversiblePasswordEncryption)','
			 $($ADcomputer.CannotChangePassword)','
			 $($ADcomputer.DoesNotRequirePreAuth)','
			 $($ADcomputer.Enabled)','
			 $($ADcomputer.HomedirRequired)','
			 $($ADcomputer.isCriticalSystemObject)','
			 $($ADcomputer.MNSLogonAccount)','
			 $($ADcomputer.PasswordExpired)','
			 $($ADcomputer.PasswordNeverExpires)','
			 $($ADcomputer.PasswordNotRequired)','
			 $($ADcomputer.ProtectedFromAccidentalDeletion)','
			 $($ADcomputer.TrustedForDelegation)','
			 $($ADcomputer.TrustedToAuthForDelegation)','
			 $($ADcomputer.UseDESKeyOnly)'
			)
GO
*/
