winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config @{MaxTimeoutms="1800000"}
winrm set winrm/config/winrs @{MaxMemoryPerShellMB="800"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/client/auth @{Basic="true"}
winrm set winrm/config/listener?Address=*+Transport=HTTP @{Port="5985"} 

netsh advfirewall firewall set rule group="remote administration" new enable=yes 
netsh firewall add portopening TCP 5985 "Port 5985" 

net stop winrm 
sc config winrm start= auto
net start winrm

c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v HideFileExt /t REG_DWORD /d 0 /f
c:\Windows\System32\reg.exe ADD HKCU\Console /v QuickEdit /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v Start_ShowRun /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v StartMenuAdminTools /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateFileSizePercent /t REG_DWORD /d 0 /f
c:\Windows\System32\reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateEnabled /t REG_DWORD /d 0 /f

wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE
a:\microsoft-updates.bat