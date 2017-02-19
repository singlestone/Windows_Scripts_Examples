'====================
'= Script:	software_inv-sql-output.vbSaturday	Project: Server Software Audit Automation
'= Created by Louie Corbo
'= Date: 9/9/2015
'=======================
'= Scope: Script Outputs the contents of db_sw_inv.sw_Scan_current and outputs it to a TSV
'=	File in share folder "S:\network\Report\Server_Software\
'= <Data>_SoftwareInventory(Servers).TSV
'= Depends: MySQL ODBC 5.1 Driver, Run from account with read access to AD and domain PCs
'= registry entries, MySQL account with write access to MySQL table.
'====================

	'Sets the path where the report will be stored.
CONST FILEPATH = "\\filestore\it\desktop\Reports\Desktop_Software\"

	'Sets the name of the report.
Dim Filename
	Filename = 	Year(Now) & _
				Right("0" & Month(Now) ,2) & _
				Right("0" & Day(Now),2) & "_" & _ 
				"SoftwareInventory(Desktops).TSV"
				
	'This Section establishes the MYSQL connection string.
	'Assumes MySQL ODBC 5.1 Driver is installed on Machine running the script.
Dim conn: Set conn = CreateObject("ADODB.Connection")
conn.Open	"Driver={MySQL ODBC 5.1 Driver};" & _
				"Server=Pistoles;" & _
				"Database=db_sw_inv;" & _
				"User=soft_scan;" & _ 
				"Password=*******;"
				
Dim cmd : Set cmd = CreateObject("ADODB.Command")

Set cmd.ActiveConnection = conn
	'This is the SQL query, this query can be altered to produced more targeted results.
	cmd.CommandText = "SELECT * FROM db_sw_inv.sw_scan_current_desktop;"
	cmd.CommandText = 1 ''# adCmdText Command text is a SQL query
Dim rs : Set rs = cmd.Execute
Dim fs : Set fs = CreateObject("Scripting.FileSystemObject")

Dim textStream : Set textStream = fs.OpenTextFile(FILEPATH & Filename , 8, True)
	'Sets the titles of each row.
	textStream.WriteLine "scan_id" & vbTab & "state" $ vbTab & "machine_name" & vbTab & "DisplayName" & vbTab & "Publisher" & vbTab & "Uninstallstring" & vbTab & "InstallDate" & vbTab & "InstallLocation" & vbTab & "InstallSource" & vbTab & "URLInfoAbout" & vbTab & "URLUpdateInfo" & vbTab & "Display_version" & vbTab & "Version" & vbTab & "Serial_Number" & vbTab & "Arch" & vbTab & "scandate"
	
	'This loops through the results of the SQL query for line 36 and puts a tab space between each row.
Do Until rs.EOF

	textStream.Write rs("scan_id") & vbtab
	textStream.Write rs("state") & vbtab
	textStream.Write rs("machine_name") & vbtab
	textStream.Write rs("DisplayName") & vbtab
	textStream.Write rs("Publisher") & vbtab
	textStream.Write rs("Uninstallstring") & vbtab
	textStream.Write rs("InstallDate") & vbtab
	textStream.Write rs("InstallLocation") & vbtab
	textStream.Write rs("InstallSource") & vbtab
	textStream.Write rs("URLInfoAbout") & vbtab
	textStream.Write rs("URLUpdateInfo") & vbtab
	textStream.Write rs("Display_version") & vbtab
	textStream.Write rs("Version") & vbtab
	textStream.Write rs("Serial_Number") & vbtab
	textStream.Write rs("Arch") & vbTab
	textStream.WriteLine rs("scandate")
	
	rs.MoveNext
Loop

textStream.Close
rs.Close
conn.Close

	