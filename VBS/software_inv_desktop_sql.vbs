
'===================
'== Script: 		Software_inv-sql.vbs 	Project:  Server Software Audit Automation
'== Created by: 	Louie Corbo 	Date: 03/20/2013
'== Dependencies: 	MySQL ODBC 5.1 Driver, Run from account with read access to AD and domain PCs
'===================


CONST HKLM = &H80000002 'The HKEY_LOCAL_MACHINE numberical code.
CONST UninstallPath32 = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" 'The path for 32-bit applications
CONST UninstallPath64 = "SOFTWARE\wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" 'The path for 64-bit applications
CONST Architecture = "SYSTEM\CurrentControlSET\Control\Session Manager\Environment" 'The path for the Environmental location which contraols the architecture (32/64 bit).

	'This Section establishes the MYSQL connection string.
	'Assumes MySQL ODBC 5.1 Driver is installed on Machine running the script.
SET objConn = CreateObject("adodb.connection")
	objConn.Open	"Driver={MySQL ODBC 5.1 Driver};" & _
					"Server=Pistoles;" & _
					"Database=db_sw_inv;" & _
					"User=soft_scan;" & _
					"Password=******;"
					
SET objRS = CreateObject("adodb.RecordSET")

	'This drops all of the data on the table holding the most current database.
	objRS.Open "DELETE FROM sw_scan_current_desktop" m objConn
	
	'This adds a line stating the script has failed and the more current inventory is not reliable.
	'This line is deleted if the script runs correctly.
	objRS.Open "INSERT INTO sw_scan_current_desktop(" & _
				"state" & _
				") " & _
				"VALUES('" & _
				"Scan has failed" & _
				"')" , objConn
				
	'This Section establishes a connection to the domains active directory using account running the script credentials.
	'This connection will be used to grab a list of computers set in Organisation Unit (OU), the search is recursing so it will get the names
	' of computers in sub OU's. Ideally all of the computers being listed should be powered on and available for scanning their registry.
	
SET cn = CreateObject("ADODB.Connection") 'This establishing the connection to the AD.
	cn.Provider = "ADsDSOObject"
	cn.Open "Active Directory Provider"
	
SET cmd = CreateObject("ADOBD.Command")		'This runs a query to retrieve the names.
SET cmd.ActiveConnection = cn
	cmd.CommandText = "SELECT name " & _
					  "FROM 'LDAP://" & "OU=clients" & ",DC=dmx,DC=lan" & "' " & _
					  "WHERE objectClass='computer " & _
					  "ORDER BY name"
					  
SET rs = cmd.Execute	'This loads the retrieved computer names into an array.
	rs.MoveFirst		'Moves to the begining of the array to see to prepary for running each computer name through the SWscan function.
	
DO UNTIL rs.EOF		'This is the main function of the script. It loops through the array of computer names and runs either through the SWscan sub procedure.
	SWscan(rs(0))
	rs.MoveNext
LOOP

'This drops all of the data on the table holding the most current database.
objRS.Open  "DELETE FROM sw_scan_current_desktop" & _
			" Where STATE = '" & _
			"Scan has failed" & _
			"'" , objConn
			
		 cn.close		'Closes connection with Active Directory.
	objConn.close		'Closes connection with the MYSQL server.
	
	'This sub procedure SWscan (Meaning: Software Scan) Takes the input of a string scanComputer, scanComputer is the name of the computer
	'the procedure is going first attempt to access the registry of the target machine. If this fails the procedure will run an insert statement
	'to the MYSQL table which simply states the targets name and sets the status to "OFFLINE", then close out allowing the next computer on the main
	'function list to be tried. If the registry is accessed successfully then registry is checked to see if the target is 32 bit or 64 bit.
	'If it's 32 bit, only one location needs to be check for registry entries, if it's 64 bit then two locations need to be checked.
	'The actually checking of the registry is handled by an separate sub procedure called Regscan.
	
	SUB SWscan(scanComputer)
	ON ERROR RESUME Next 'Since it's possible for targets to be offline, we need to allow for connection errors to be overlooked.
	SET objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & scanComputer & "\root\cimv2")   'This is checking the registry
	
												' for the first time.
	IF err = 0 Then 'IF the error level is zero then the registry connection succeeded and we can proceed.
		SET colitems = objWMIservice.ExecQuery("Select * from Win32_BOIS") 'This section scans the target for the serial number ans stores it in
		For each objitem in colitems									   ' variable SN to be later uploaded into the MYSQL table.
			SN = objitem.serialnumber
		Next
		
		SET oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & scanComputer & "\root\default:StdRegProv")	'This is checking the registry
			oReg.GetStringValue HKLM, Architecture &"\", "PROCESSOR_ARCHITECTURE", sArch	' whether the target is running
																							' a 32 or 64 bit Windows OS.
		IF sArch = "x86" THEN	'If it's 32 bit then only on location needs to be scanned.
			CALL Regscan(UninstallPath32, scanComputer, sArch, SN)
		END IF
		
		IF sArch = "AMD64" THEN 'If it's 64 bit then two locations need to be scanned.
			CALL Regscan(UninstallPath64, scanComputer, sArch, SN)
			CALL Regscan(UninstallPath32, scanComputer, sArch, SN)
		END IF
	ELSE
			'This section assumes the first registry connection failed and thus the target is offline.  Simple insert to inform the MYSQL table of this.
		objRS.Open "INSERT INTO sw_scan_desktop(" & _
						"state" & _
						") " & _
						"VALUES('" & _
						scanComputer &"','" & _
						"Offline" & _
						"')" , objConn
		err.clear 'This resets the error level back to zero so when the next computer on the list is being targeted we do not get a false negative.
	END If
END SUB

	'This sub procedure Regscan (Meaning: Registry Scan) Takes the input strings UninstallPath, regComputer, Arch, SerialNumber and scans the targeted
	' computer (regComputer) for the remaining registry entries and then inserts them into the MYSQL table. The inputs Arch and SerialNumber and
	' simply passed onto the insert statement. UnistallPath is the location in the targets registry where information we are scanning for is
	' being kept. This veriable is going to being one of the constants established at the top of this script.

	SUB Regscan(UninstallPath, regComputer, Arch, SerialNumber)
		SET oReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & regComputer & "\root\default:StdRegProv")
			oReg.EnumKey HKLM, UninstallPath, aSUBkeys
			
		FOR EACH sSUBkey IN aSUBkeys
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "DisplayName", sDisplayName
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "UninstallString", sUninstallString
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "InstallDate", sInstallDate
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "InstallLocation", sInstallLocation
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "Publisher", sPublisher
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "DisplayVersion", sDisplayVersion
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "InstallSource", sInstallSource
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "URLInfoAbout", sURLInfoAbout
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "URLUpdateInfo", sURLUpdateInfo
			oReg.GetStringValue HKLM, UninstallPath & "\" & sSUBkey, "Version", sVersion
			
				'Replace any "\" with "\\" using the function CleanString.
			sInstallLocation =CleanString(sInstallLocation)
			sInstallSource = CleanString(sInstallSource)
			sUninstallString = CleanString(sUninstallString)
			
			IF len(sDisplayName) THEN 'If the length of the string is not null, run insert statement otherwise skip.
				objRS.Open	"INSERT INTO sw_scan_desktop(" & _
								"state, " & _
								"machine_name, " & _
								"DisplayName, " & _
								"Publisher, " & _
								"Uninstallstring, " & _
								"InstallDate, " & _
								"InstallLocation, " & _
								"InstallSource, " & _
								"URLInfoAbout, " & _
								"URLUpdateInfo, " & _
								"Diskplay_Version, " & _
								"Version, " & _
								"Serial_Number, " & _
								"Arch) " & _
							"VALUES('" & _
								"Online" &"','"& _
								regComputer &"','"& _
								sDisplayName &"','"& _
								sPublisher &"','"& _
								sUninstallString &"','"& _
								sInstallDate &"','"& _
								sInstallLocation &"','"& _
								sInstallSource &"','"& _
								sURLInfoAbout &"','"& _
								sURLUpdateInfo &"','"& _
								sDisplayVersion &"','"& _
								Version &"','"& _
								SerialNumber &"','"& _
								Arch & _
								"')", objConn
			END IF
			IF Len(sDisplayName) Then		'IF the length of the string is not null, run insert statement otherwise skip.
				objRS.Open	"INSERT INTO sw_scan_current_desktop(" & _
								"state, " & _
								"machine_name, " & _
								"DisplayName, " & _
								"Publisher, " & _
								"Uninstallstring, " & _
								"InstallDate, " & _
								"InstallLocation, " & _
								"InstallSource, " & _
								"URLInfoAbout, " & _
								"URLUpdateInfo, " & _
								"Diskplay_Version, " & _
								"Version, " & _
								"Serial_Number, " & _
								"Arch) " & _
							"VALUES('" & _
								"Online" &"','"& _
								regComputer &"','"& _
								sDisplayName &"','"& _
								sPublisher &"','"& _
								sUninstallString &"','"& _
								sInstallDate &"','"& _
								sInstallLocation &"','"& _
								sInstallSource &"','"& _
								sURLInfoAbout &"','"& _
								sURLUpdateInfo &"','"& _
								sDisplayVersion &"','"& _
								Version &"','"& _
								SerialNumber &"','"& _
								Arch & _
								"')", objConn
			END IF
		NEXT
	END SUB
	
		' This function takes a string if it's not null it will replace an "\" with "\\". If the string is null it will return the string unchanged.
	FUNCTION CleanString(Regstring)
		IF Len(RegString THEN 'If the length of the string is not null, run the search and replace function on the string, otherwise skip.
			RegString = Replace(RegString, "\", "\\")	'Replace any "\" with "\\"
		END IF
		RETURN = RegString
	END FUNCTION
	