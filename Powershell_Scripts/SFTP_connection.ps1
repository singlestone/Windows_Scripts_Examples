Function Open-SFTPSession {

    # Load WinSCP .NET assembly
    Add-Type -Path ".\DLL\WinSCPnet.dll"
     # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions
    $sessionOptions.Protocol = [WinSCP.Protocol]::Sftp
    $sessionOptions.HostName = '192.168.209.219'
    $sessionOptions.UserName = 'UserName'
    $sessionOptions.Password = 'password'
    $sessionOptions.SshHostKeyFingerprint = 'ssh-rsa 2048 78:25:df:0f:bd:6d:d1:d3:2d:46:26:92:20:1c:c8:ae'
     $session = New-Object WinSCP.Session
	return $session

        # Connect
        $session.Open($sessionOptions)
 
        # Get list of files in the directory
        $directoryInfo = $session.ListDirectory("/")
 
        # Select files matching wildcard
        $files =
            $directoryInfo.Files |
            Where-Object { $_.Name -Like "*" }
 
        # Any file matched?
        if ($files)
        {
            foreach ($fileInfo in $files)
            {
                Write-Host ("{0} with size {1}, permissions {2} and last modification at {3}" -f
                    $fileInfo.Name, $fileInfo.Length, $fileInfo.FilePermissions, $fileInfo.LastWriteTime)
            }
        }
        else
        {
            Write-Host ("No files matching {0} found" -f "*")
        }
    
    finally{
        # Disconnect, clean up
        $session.Dispose()
    }
    exit 0

}

Open-SFTPSession