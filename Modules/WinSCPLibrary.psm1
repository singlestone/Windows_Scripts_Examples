<#------------------------------------------------------------------------
Script   	: WinSCPLibrary.ps1
Author   	: Bill.Grauer@Microsoft.com
Date     	: 12/27/12
Keywords 	: Secure FTP, SFTP, WinSCP
Comments 	: WinSCP Secure FTP library 
For complete WinSCP .NET support information visit http://winscp.net/eng/index.php.

Disclaimer	: The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, 
its authors, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages 
for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts 
or documentation, even if Microsoft has been advised of the possibility of such damages.
--------------------------------------------------------------------------#>  
#requires -version 2.0 

#Default install location of WinSCP

Set-Variable -Name WinSCPInstallPath -Value "C:\Program Files (x86)\WinSCP"


Function Test-WinSCPAssemblyLoaded
{

<#
.SYNOPSIS
Test if WinSCP.DLL assembly is loaded. 

.DESCRIPTION
The Test-WinSCPAssemblyLoaded function calls [AppDomain]::CurrentDomain.GetAssemblies() to determine 
if the WinSCP.DLL assembly has been previously loaded.

.INPUTS
None.  You cannot pipe objects to Test-WinSCPAssemblyLoaded.

.OUTPUTS
System.Boolean. Test-WinSCPAssemblyLoaded returns a boolean value indicating whether or not
the assembly has been loaded.

.EXAMPLE
$AssemblyFound = Test-WinSCPAssemblyLoaded

.EXAMPLE
if(Test-WinSCPAssemblyLoaded){Write-Host "Assembly Found"}

.LINK
http://msdn.microsoft.com/en-us/library/system.appdomain.getassemblies.aspx
#>

    
    if(([AppDomain]::CurrentDomain.GetAssemblies() -Like "WinSCP*").count -gt 0)
    {
        return $true
    }
    else
    {
        return $false
    }


}#end Test-WinSCPAssemblyLoaded

Function Add-WinSCPAssembly
{

<#
.SYNOPSIS
Loads the WinSCP Assembly if needed.

.DESCRIPTION
The Add-WinSCPAssembly will attempt to load the WinSCP.DLL assembly from it's default file location if it's
both present and not currently loaded.  The assembly is currently loaded by calling [Reflection.Assembly]::LoadFrom().

.INPUTS
NONE

.OUTPUTS
System.Boolean.  Add-WinSCPAssembly returns a boolean indicating whether the assembly has been loaded.

.EXAMPLE
Add-WinSCPAssembly

.LINK
http://msdn.microsoft.com/en-us/library/system.reflection.assembly.loadfile.aspx
http://www.leeholmes.com/blog/2006/01/17/how-do-i-easily-load-assemblies-when-loadwithpartialname-has-been-deprecated/

#>    
    
    # Load WinSCP .NET assembly
    # Test-Path to be sure WinSCP.DLL resides where we expect it too be
    if (Test-Path "$WinSCPInstallPath\WinSCP.dll")
    {
        #Only attempt if the assembly is NOT already loaded
        if(!(Test-WinSCPAssemblyLoaded))
        {
            try
            {
                Import-Module $WinSCPInstallPath\WinSCP.dll
                #[Reflection.Assembly]::LoadFrom("$WinSCPInstallPath\WinSCP.dll") | Out-Null
                Write-Host -ForegroundColor Cyan "WinSCP.DLL loaded successfully..."
                
            }
            catch [Exception]
            {
                Write-Host -ForegroundColor Red "[Add-WinSCPAssembly]$_ occurred attempting to load the WinSCP Assembly"
                
            }
        }
        else
        {
            Write-Host -ForegroundColor Cyan "WinSCP.DLL loaded..."
            
        }
    }
    else
    {
        Write-Host -ForegroundColor Red "[Add-WinSCPAssembly]WinSCP.DLL was not found at $WinSCPInstallPath where it's expected.."
        
    }

}#end Add-WinSCPAssembly

Function Set-SFTPSessionOption 
{

<#
.SYNOPSIS
Used to set the various WinSCP.SessionOption parameters

.DESCRIPTION
WinSCP.Session connection supports several connection options.  These options can be configured with the Set-SFTPSessionOption function.

.PARAMETER HostName
FQDN of the SFTP server address we wish to connect to.

.PARAMETER UserName
User name of account that has access to remote SFTP host.

.PARAMETER Password
Password for UserName account.

.PARAMETER SshHostKey
SSH/RSA Server host key.

.OUTPUTS
WinSCP.SessionOptions object

.EXAMPLE
Set-SFTPSessionOption -HostName "localhost" -UserName "test" -Password "test" -SshHostKey "ssh-rsa 1024 ea:71:f8:76:bd:ba:57:c2:22:d6:0f:06:b8:4a:96:4c"

.LINK
http://winscp.net/eng/docs/ssh for more information.
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$HostName,
    [Parameter(Mandatory=$true)] 
    [string]$UserName, 
    [Parameter(Mandatory=$true)]
    [string]$Password,
    [Parameter(Mandatory=$true)] 
    [string]$SshHostKey
)#end Param
    
try
{
    #Import the WinSCP assembly if needed    
    Add-WinSCPAssembly
     
    # Setup session options
    $so = $null
    $so = New-Object WinSCP.SessionOptions
    $so.Protocol = [WinSCP.Protocol]::Sftp
    $so.HostName = "$HostName"
    $so.UserName = "$UserName"
    $so.Password = "$Password"
    $so.SshHostKeyFingerprint = $SshHostKey #"ssh-rsa 1024 ea:71:f8:76:bd:ba:57:c2:22:d6:0f:06:b8:4a:96:4c"

    $so 
       
}#end Try

catch [Exception]
{
    Write-Host -ForegroundColor red "[Set-SFTPSessionOptions]$_.Exception.Message"
    exit 1
}

}#end Set-SFTPSessionOptions

Function Open-SFTPSession
{

<#
.SYNOPSIS
Call to open a connection to a remote SFTP server

.DESCRIPTION
This is the main interface to WinSCP SFTP functionallity.  Use this command to open a session to a remote SFTP server, 
allowing upload/download functionallity.

.PARAMETER HostName
FQDN of the SFTP server address we wish to connect to.

.PARAMETER SessionOptions
Object containing various session connection specific options like host name, user name and protocol.

.PARAMETER AdditionalExecutableArguments
Additional command-line arguments to be passed to winscp.com. In general, this should be left with default null. 

.PARAMETER SessionLogPath
 Path to store session log file to. Default null means, no session log file is created. See also DebugLogPath.  

.PARAMETER DebugLogPath
Path to store assembly debug log to. Default null means, no debug log file is created. See also SessionLogPath. 

.PARAMETER DefaultConfiguration
Should WinSCP be forced with the default configuration? true by default. Useful to isolate the console session 
run from any configuration stored on this machine. Set to false only in an exceptional scenarios. 

.PARAMETER DisableVersionCheck
 Disables test that WinSCP executables have the same product version as this assembly.

.PARAMETER ExecutablePath
Path to winscp.exe. The default is null, meaning that winscp.exe is looked for in the same directory as this assembly
or in an installation folder. 

.PARAMETER IniFilePath
Path to an INI file. Used only when DefaultConfiguration is false. When null, default WinSCP configuration storage is used, 
meaning INI file, if any is present in WinSCP startup directory, or Windows Registry otherwise.

.OUTPUTS
WinSCP.SessionOptions object

.EXAMPLE
Set-SFTPSessionOption -HostName "localhost" -UserName "test" -Password "test" -SshHostKey "ssh-rsa 1024 ea:71:f8:76:bd:ba:57:c2:22:d6:0f:06:b8:4a:96:4c"

.LINK
http://winscp.net/eng/docs/library_session#methods
#>



Param(
    [Parameter(Mandatory=$true)]
    $sessionOptions,
    [String]$AdditionalExecutableArguments = $null,
    [String]$SessionLogPath = $null,
    [String]$DebugLogPath = $null,
    [Bool]$DefaultConfiguration = $true,
    [Bool]$DisableVersionCheck = $false,
    [String]$ExecutablePath = $null,
    [String]$IniFilePath = $null
    
)#end Param

Try
{
    $s = New-Object WinSCP.Session
    $s.DebugLogPath = $DebugLogPath
    $s.SessionLogPath = $SessionLogPath
    $s.AdditionalExecutableArguments = $AdditionalExecutableArguments
    $s.DefaultConfiguration = $DefaultConfiguration
    $s.DisableVersionCheck = $DisableVersionCheck
    $s.ExecutablePath = $ExecutablePath
    $s.IniFilePath = $IniFilePath
    
    $s.Open($sessionOptions)
    Write-Host -ForegroundColor Cyan "Session Opened successfully to $($sessionOptions.hostName)..."
    return $s

}#end Try
catch [Exception]
{
    Write-Host -ForegroundColor red "[Open-SFTPSession] $_"
    break
}


}#end Open-SFTPSession

Function Close-SFTPSession
{

<#
.SYNOPSIS
Used to close a previously opened SFTP session.

.DESCRIPTION
Calls the [WinSCP]::Dispose() method and terminates the underlying WinSCP connection and process.

.PARAMETER Session
Session object we wish to close and clean up.

.EXAMPLE
Close-SFTPSession -Session $session

.LINK
http://winscp.net/eng/docs/library_session_dispose

#>



Param(
    [WinSCP.Session]$Session
)#end Param

# Disconnect, clean up
$session.Dispose()
Write-Host -ForegroundColor Cyan "Session closed"

}#end Close-SFTPSession       
 
Function Write-ToSFTPServer ()
{

<#
.SYNOPSIS
Upload a file to the specified SFTP path.

.DESCRIPTION
Uploads the specified file from a local path to the remote path.


.PARAMETER Session
Session object 

.PARAMETER SourcePath
Full path to local file or directory to upload. Filename in the path can be replaced with Windows wildcard
to select multiple files. When file name is omitted (path ends with backslash), all files and subdirectories 
in the local directory are uploaded. 

.PARAMETER TransferMode
Transfer mode. Possible values are TransferMode.Binary (default), TransferMode.Ascii and TransferMode.Automatic (based on file extension). 

.PARAMETER RemotePath
Full path to upload the file to. When uploading multiple files, the filename in the path should be replaced 
with operation mask or omitted (path ends with slash). 

.PARAMETER DeleteSource
When set to true, deletes source local file(s) after transfer. Defaults to false.  

.EXAMPLE
Write-ToSFTPServer -Session $Session -SourcePath "c:\ToUpload\MyUploadedTextFile.txt" -TransferMode binary


.LINK
http://winscp.net/eng/docs/library_session_putfiles

#>



Param(
    [Parameter(Mandatory=$true)]
    [WinSCP.Session]$Session,
    [Parameter(Mandatory=$true)] 
    [string]$SourcePath,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Binary","Ascii","Automatic")]
    [String]$TransferMode,
    [string]$RemotePath = "./", 
    [switch]$DeleteSource
)#end Param

# Create new TransferOptions object
Set-Variable -Name transferOptions -value $null
$transferOptions = New-Object WinSCP.TransferOptions

switch($TransferMode)
{
    "Binary"{$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary}
    "Ascii" {$transferOptions.TransferMode = [WinSCP.TransferMode]::Ascii}
    "Automatic" {$transferOptions.TransferMode = [WinSCP.TransferMode]::Automatic}
}

 
Set-Variable -name transRslts -Value $null
$transRslts = $Session.PutFiles($SourcePath, $RemotePath, $DeleteSource, $transferOptions)
 
# Call the TransferResults Check method to see if any errors occurred.
if($transRslts.failures.count -gt 0)
{
        
    Write-Host -ForegroundColor red "[Write-ToSFTPServer] - $($transRslts.Failures)"
}
else
{
    # Print results
    foreach ($transfer in $transRslts.Transfers)
    {
        Write-Host -ForegroundColor green ("Upload of {0} succeeded" -f $transfer.FileName)
    }
}

return $transRslts

}#end Write-ToSFTPServer

Function Read-FromSFTPServer
{

<#
.SYNOPSIS
Download a file from the specified SFTP path.

.DESCRIPTION
Retrieved on or more files from a remote directory using [WinSCP]::GetFiles() method.

.PARAMETER Session
Session object 

.PARAMETER LocalPath
Full path to download the file to. When downloading multiple files, the filename in the path should be replaced with 
operation mask or omitted (path ends with backslash). 

.PARAMETER remotePath
Full path to remote directory followed by slash and wildcard to select files or subdirectories to download. 
When wildcard is omitted (path ends with slash), all files and subdirectories in the remote directory are downloaded.

.PARAMETER DeleteSource
When set to true, deletes source remote file(s) after transfer. Defaults to false.
    
.EXAMPLE
Read-FromSFTPServer -Session $session -LocalPath "c:\SFTPDownLoads\SomeFileWeDownloaded" -remotePath "SomeFileWeDownloaded"

.LINK
http://winscp.net/eng/docs/library_session_getfiles  

#>



Param(
    [Parameter(Mandatory=$true)]
    [WinSCP.Session]$Session,
    [Parameter(Mandatory=$true)] 
    [string]$LocalPath,
    [Parameter(Mandatory=$true)]
    [string]$remotePath, 
    [switch]$DeleteSource
)#end Param

# Create new TransferOptions object
Set-Variable -Name transferOptions -value $null
$transferOptions = New-Object WinSCP.TransferOptions
#Possible we should take this as a param?
$transferOptions.TransferMode = [WinSCP.TransferMode]::Binary

Set-Variable -name transRslts -Value $null

if($Session.FileExists($remotePath))
{
    $transRslts = $Session.GetFiles($RemotePath, $LocalPath, $DeleteSource, $transferOptions)

    # Call the TransferResults Check method to see if any errors occurred.
    if($transRslts.failures.count -gt 0)
    {
        
        Write-Host -ForegroundColor red "[Read-FromSFTPServer] - $($transRslts.Failures)"
    }
    else
    {
        # Print results
        ForEach ($transfer in $transRslts.Transfers)
        {
            Write-Host -ForegroundColor green ("Download of {0} succeeded" -f $transfer.FileName)
        }
    }
}#end if FileExists
else
{
    Write-Host -ForegroundColor red "[Read-FromSFTPServer] - ERROR: $RemotePath not found on server"
}

return $transRslts

    
}#end Read-FromSFTPServer 









 