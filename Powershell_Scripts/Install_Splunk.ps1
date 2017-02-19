# Install_Splunk_F.ps1
# Install's SPlunk Forwarder on server
# Requires output.conf and %HOSTNAME%_input.conf to be present in the same directory as the install script

# This will return the directory the script is located in.
function Get-ScriptDirectory
{
    Split-Path $script:MyInvocation.MyCommand.Path
}

# Sets the the path of the scripts directory as the root path.
$root = Get-ScriptDirectory

# The Arguments for install the Splunk Forwarder's MSI
$Arguements = "/i $root\splunkforwarder-6.4.0-f2c836328108-x64-release.msi AGREETOLICENSE=Yes /q"

# Location of the output.conf file.
$Output_Path = "$root\output_configs\outputs.conf"

# Location of the input.conf file.
$Input_Path_Apps = "$root\input_configs\$env:computername\apps\*"
$Input_Path_system = "$root\input_configs\$env:computername\system\local\inputs.conf"


# First run a quick test to make sure the paths exist, if not fail out of the script, otherwise proceed.
if(!(Test-Path $Output_Path)){
    Write-Host "Error!!! File $Output_Path Not Found, Quiting"
    Exit
}
Elseif(!(Test-Path $Input_Path_system)){
    Write-Host "Error!!! File $Input_Path_system Not Found, Quiting"
    Exit
}
Elseif(!(Test-Path $Input_Path_Apps)){
    Write-Host "Error!!! File $Input_Path_Apps Not Found, Quiting"
    Exit
}
Else{
    # Install the Application
    Start-Process -FilePath msiexec.exe -ArgumentList $Arguements -wait

    # Copy the Configuration Files
    Copy-Item -Path $Output_Path -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\outputs.conf'
    Copy-Item -Path $Input_Path_Apps -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\apps' -recurse -force
    Copy-Item -Path $Input_Path_system -Destination 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf'

    # Restart the service 
    Restart-Service SplunkForwarder
}

#Assuming no errors, Splunk is not gathering log data from this server!