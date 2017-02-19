'=======================
'= Depends: Assumes all Developers Machines are in there own OU in AD.
'=======================

DIM oFSO : SET oFSO = CreateObject("Scripting.FileSystemObject")
DIM objShell : SET objShell = CreateObject("Wscript.Shell")
SET cn = CreateObject("ADODB.Connection")	'This establishing the connection to the AD.
	cn.Provider = "ADsDSOObject"
	cn.Open "Active Directory Provider"
SET cmd = CreateObject("ADODB.Command")		"This runs a query to retrieve the names.
SET cmd.ActiveConnection = cn
	cmd.CommandText = "SELECT name " & _
					  "FROM 'LDAP://" & "OU=Developer" & ",OU=Windows 7" & ",OU=Desktops" & ",OU=Clients" & ",DC=DMX,DC=lam" & "' " & _
					  "WHERE objectClass='computer' " & _
					  "ORDER BY name"
SET rs = cmd.Execute	'This loads the retrieved computer names into an array.
	rs.MoveFirst		'Moves to the beginning of the array to see to prepare for running each computer name through the Dev_backup sub routine.
DO UNTIL rs.EOF			'This is the main function of the script. it loops through the array of computer names and runs either through the SWscan sub procedure/
	call Dev_backup(rs(0)), ROBOCOPYPATH, ROBOCOPYPATH_SWITCH)
	rs.MoveNext
LOOP
	cn.close			'Closes connection with Active Directory.
	
SUB Dev_backup(DEV_MACHINE, SUB_ROBOCOPYPATH, SUB_ROBOCOPYPATH_SWITCH)
	CONST LOGPATH = "F:\Dev_Backups\LOGS\"
	CONST LOGNAME = "Dev_Backups"
	CONST ROBOCOPYPATH = "F:\Dev_Backups\_Tools\robocopy.exe"
		  SOURCE = "\\" & DEV_MACHINE & "\c$\"
		  DESTINATION = "F:\Dev_Backups\" & DEV_MACHINE
		  ROBOCOPYPATH_SWITCH = "/MIR " &_ 
								"/ZB" &_ 
								"/E " &_ 
								"/W:0 " &_ 
								"/R:0 " &_ 
								"/V " &_ 
								"/FP " &_ 
								"/NFL " &_ 
								"/NDL " &_ 
								"/XF " &_ 
									SOURCE & "hiberfil.sys " &_ 
									SOURCE & "pagefile.sys " &_ 
									SOURCE & "bootmgr " &_ 
									SOURCE & "BOOTSECT.BAK " &_ 
								"/XD " &_ 
									SOURCE & "WINDOWS " &_ 
									SOURCE & "USERS " &_ 
									SOURCE & "temp " &_ 
									SOURCE & "Boot " &_ 
									SOURCE & "Audit " &_ 
									SOURCE & "ProgramData " &_ 
									SOURCE & "MSOCache " &_ 
									Chr(34) & SOURCE & "Application Data" & Chr(34) & " " &_ 
									Chr(34) & SOURCE & "Documents and Settings" & Chr(34) & " " &_ 
									Chr(34) & SOURCE & "Programs Files" & Chr(34) & " " &_ 
									Chr(34) & SOURCE & "Programs Files (x86)" & Chr(34) & " " &_ 
									Chr(34) & SOURCE & "System Volume Information" & Chr(34) & " " &_ 
									SOURCE & "$RECYCLE.BIN " &_ 
									SOURCE & "dfsrprivate " &_ 
									SOURCE & "RECYCLER " &_ 
									SOURCE & "BOOT " &_ 
								"/log+:" & LOGPATH & LOGNAME & "_" & DEV_MACHINE & ".log"
	COMPUTERNAME = DEV_MACHINE
	CALL ROTATELOG(LOGPATH, LOGNAME, DEV_MACHINE)
	IF NOT(oFSO.FolderExists("F:\Dev_Backups\" & DEV_MACHINE)) THEN
		oFSO.createfolder "FL\Dev_Backups\" & DEV_MACHINE
	END IF
	objShell.Run ROBOCOPYPATH & " " & "\\" & DEV_MACHINE & "\c$\ F:\Dev_Backups\" & DEV_MACHINE & " " & SUB_ROBOCOPYPATH_SWITCH, 1, True
END Sub


'Cycles the log files and to keep the last seven days worth.
SUB ROTATELOG(SUB_LOGPATH, SUB_LOGNAME, SUB_DEV_MACHINE)
	IF (oFSO.FileExists(SUB_LOGPATH & SUB_LOGNAME & "_" SUB_DEV_MACHINE & ".6.log"))
	THEN
		oFSO.DeleteFile SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & ".6.log"
	END IF
	DIM index : index = 5
	DO WHILE index >= 0
		IF (oFSO.FileExists(SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & "." & index & ".log")) THEN
			oFSO.movefile SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & "." & index & ".log", SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & "." & index +1 & ".log"
		END IF
		index = index - 1
	LOOP 
	IF (oFSO.FileExists(SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & ".log")) Then
		oFSO.movefile SUB_LOGPATH & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & ".log",SUB_LOGNAME & SUB_LOGNAME & "_" & SUB_DEV_MACHINE & ".1.log"
	END IF
END SUB
									
									