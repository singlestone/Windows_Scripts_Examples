
Import-Module -force '.\Modules\WinSCPLibrary_Dav.psm1'

$HostName   = '192.168.2.219'
$UserName   = 'username'
$Password   = 'password'
$SshHostKey = 'ssh-rsa 2048 78:25:df:0f:bd:6d:d1:d3:2d:46:26:92:20:1c:c8:ae'

$TEST = Set-SFTPSessionOption $HostName $UserName $Password $SshHostKey
#TEST.ListDirectory('/')
$results = Find-FromSFTPServer $TEST '/' '*.pgp'

foreach ($result in $results)
{
    $result.Name
}

Close-SFTPSession