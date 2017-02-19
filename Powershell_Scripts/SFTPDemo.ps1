#requires -version 2.0

<#------------------------------------------------------------------------
Script   	: SFTPTasks.ps1
Author   	: Bill.Grauer@Microsoft.com
Date     	: 12/27/12
Keywords 	: Secure FTP, SFTP, WinSCP
Comments 	: WinSCP Secure FTP example script using WinSCP Library module
For complete WinSCP .NET support information visit http://winscp.net/eng/index.php.

Disclaimer 	: The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, 
its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages 
for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts 
or documentation, even if Microsoft has been advised of the possibility of such damages.
--------------------------------------------------------------------------#>  

cls

#TODO: Change this to a module...
Import-Module WinSCPLibrary

<#
$credToDisk = Get-Credential
$credToDisk.Password | ConvertFrom-SecureString | Set-Content "c:\temp\password.txt"

#retrieve previously stored enctryped password from file
$cred = New-Object System.Management.Automation.PsCredential "test",(Get-Content c:\temp\password.txt| ConvertTo-SecureString)

#convert secureString to String
[String]$password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password))
#>

#Setup the connection Options 
$sessionOptions = Set-SFTPSessionOption -HostName localhost -UserName testUser -Password "testUser" -SshHostKey "ssh-rsa 1024 fd:6b:73:e4:52:b2:56:ac:2a:fb:a8:64:53:ca:59:90"

#Create and open session to remote host
$Session = Open-SFTPSession -sessionOptions $sessionOptions -SessionLogPath "c:\temp\sessionLog.txt"

#Upload files to host
#$transferResults = Write-ToSFTPServer -Session $Session -SourcePath "c:\ToUpload\MyUploadedTextFile1.txt" -RemotePath $DEVWFUploadPath  -TransferMode binary 

#Download files from host
$ReadResults = Read-FromSFTPServer -Session $session -RemotePath ".\Downloads\mytestFile.txt" -LocalPath "c:\temp\MyFileIDownloaded.txt"

#clean up connection object
Close-SFTPSession -Session $session