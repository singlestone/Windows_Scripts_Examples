## SignScript PS file
## This script signes a powershell script for use with remote execution.
## This script is reliant of the file MakeCert which can be obtained at:
## https://msdn.microsoft.com/en-us/library/windows/desktop/aa386968%28v=vs.85%29.aspx
## Louie Corbo
## 5/22/2015

$MAKECERTDIR = 'C:\Users\lcorbo\Downloads'

$PSFilePath = 'C:\Users\lcorbo\Downloads\Last installed update.ps1'

$MAKECERT = 'C:\Users\lcorbo\Downloads\makecert.exe'
& $MAKECERT `
    -n "CN=PowerShell Local Certificate Root" `
    -a sha1 `
    -eku 1.3.6.1.5.5.7.3.3 `
    -r `
    -sv root.pvk root.cer `
    -ss Root `
    -sr localMachine
    
& $MAKECERT `
    -pe `
    -n "CN=PowerShell User" `
    -ss MY `
    -a sha1 `
    -eku 1.3.6.1.5.5.7.3.3 `
    -iv root.pvk `
    -ic root.cer

$cert = Get-ChildItem -Path cert:\CurrentUser\my -CodeSigningCert

Set-AuthenticodeSignature $PSFilePath -certificate $cert




$Thumb = New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -dnsname cert.invest.com

         New-SelfSignedCertificate -DnsName www.nwtraders.com -CertStoreLocation Cert:\LocalMachine\My

$pwd = ConvertTo-SecureString -String "G3Z!nger$" -Force -AsPlainText

$CertPath = "cert:\localMachine\my\" + $Thumb.Thumbprint

Export-PfxCertificate -cert $CertPath -FilePath $FilePath -Password $pwd

$cert = Get-PfxCertificate $FilePath

Set-AuthenticodeSignature -Filepath $PSFilePath -Cert $cert 