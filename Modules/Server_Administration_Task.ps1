# Administration task function for configuring Windows 2012 servers.
# Written by Louie Corbo
# Still being Tested, do not use in production.
# Date 5/11/2015

# Configures a Network Device to a static IPaddress. 
# Tested successfully 5/20/2015 
Function NET_INT_CONF() {
	param(
		[string]$IP_Address_LF,
		[string]$InterfaceAlias_LF,
		[string]$Subnetmask_LF,
		[string]$Gatway_LF,
		[string]$DNS_Server_Prime_LF,
		[string]$DNS_Server_Sec_LF
		);

	Write-Host "Configuring NIC $InterfaceAlias_LF....."
	# I use netsh because it works and all tested cmdlets don't.
	netsh interface ip set `
		address name = $InterfaceAlias_LF `
		static `
		$IP_Address_LF `
		$Subnetmask_LF `
		$Gatway_LF `

	#Interestingly enough the DNS cmdlet works just fine.
	Set-DnsClientServerAddress `
		-InterfaceAlias  $InterfaceAlias_LF `
		-ServerAddresses $DNS_Server_Prime_LF, `
						 $DNS_Server_Sec_LF
					 
	Write-Host "NIC InterfaceAlias_LF has been configured to use the static IP: $IP_Address_LF"
	Write-Host "Configuration is a follows..."
	Write-Host "Gateway: 		$Gatway_LF"
	Write-Host "Subnet mask: 	$Subnetmask_LF"
	Write-Host "DNS Primary: 	$DNS_Server_Prime_LF"
	Write-Host "DNS Secondary: 	$DNS_Server_Sec_LF"
	Write-Host "NIC Configuration Complete."	 
}	

# Returns true if Parameter can be used to create a new volume, otherwise returns false. 
# Requires drive to be the format "D:\"
# Tested successfully 5/20/2015
Function Test_Drive() {
	param(
		[string]$Drive_Letter_LF
	)	
	If((($Drive_Letter_LF.length -ne 3) -or ($Drive_Letter_LF.Substring(1) -ne ':\'))) {
		Write-Host "The Drive Letter Parameter was not properly formatted.  Cancelling Task."
		Return $false
	}
	ElseIf (($Drive_Letter_LF -eq "A:\")) {
		Write-Host "The Letter A:\ is reserved for the floppy drives."    
        Return $false
    }
	ElseIf (($Drive_Letter_LF -eq "B:\")) {
		Write-Host "The Letter B:\ is reserved for the floppy drives."    
		Return $false
    }
	ElseIf (($Drive_Letter_LF -eq "C:\")) {
		Write-Host "The Letter C:\ is reserved for the OS drive."    
		Return $false
    }
	ElseIf (($Drive_Letter_LF -eq "D:\")) {
		Write-Host "The Letter B:\ is reserved for the  drives."    
        Return $false
    }
    ElseIf (($Drive_Letter_LF -eq "U:\")) {
        Write-Host "The Letter U:\ is reserved for the mapped drives."    
        Return $false
    }
    ElseIf (($Drive_Letter_LF -eq "X:\")) {
        Write-Host "The Letter X:\ is reserved for the mapped drives."     
        Return $false
    }
    ElseIf ((Test-Path $Drive_Letter_LF)) {
		Write-Host "Drive $Drive_Letter already exists."
		Return $false
	}
	Return $True
}

# PowerShell Script to Display File Size
# Tested successfully 5/20/2015
Function DiskSize_Cleanup() {
    [cmdletbinding()]
	param(
        [DOUBLE]$rawsize
        )
    Write-Host "Drive Size reported as $rawsize, Cleaning up..."
	# Raw size number goes in, formatted approximate output comes out.  You can't explain that.
		If($rawsize -ge 1TB) {
		$result = [string]::Format("{0:0.00} GB", $rawsize / 1GB)
		}
	ElseIf($rawsize -ge 1GB) {
		$result = [string]::Format("{0:0.00} GB", $rawsize / 1GB)
		}
	ElseIf($rawsize -ge 1MB) {
		$result = [string]::Format("{0:0.00} MB", $rawsize / 1MB)
		}
	ElseIf($rawsize -ge 1KB) {
		$result = [string]::Format("{0:0.00} KB", $rawsize / 1KB)
		}
	ElseIf($rawsize -gt 0) {
		$result = [string]::Format("{0:0.00} Bytes", $rawsize)
		}
	# If all else fails, quit.
	Else{
		$rawsize = ""
        Write-Host "Bad input!"
        return
        }
    Write-Host "Drive formate to read as $result."
	Write-Host "Cleaning up yet again to compare with expected $result...."
	#If the output is not in GB then raw disk is too small for this script to process.
	#This part strips the formatting so that it can be compared to the expected size parameter.
	If($result.substring($result.Length - 2, 2) -eq "GB"){
		$result = $result.Substring(0, $result.IndexOf('.'))
		Write-Host "Final Output is $result"
		return $result
	}
	Else {
		Write-Host "Error, it looks like the size is off.  Either the drive is too small, or no disk was available."
		return
	}
}

# Configures the Application Data Drive
# Tested successfully 5/20/2015
Function App_Drive_CONF() {
	param(
		[string]$Drive_Letter_LF,
		[INT]$Drive_Size_LF
		);
	Write-Host "Configuring Application Drive $Drive_Letter_LF...."
	Write-Host "Drive is expecting to be $Drive_Size_LF (GB), checking the attached raw disk to confirm...."
	# This makes sure the selected drive letter that will be used is not already assigned.
	If(!(Test_Drive $Drive_Letter_LF)) {
		Write-Host "The $Drive_Letter_LF is not valid, the application drive can be configured."
		Return
	}
	
	# Geting information on newly added Disk.
	$Disk = Get-Disk | Where partitionstyle -eq 'raw'
		
	# Making sure only one disk was added, if more disks were added this script is likely being executed by mistake.
	If( ($Disk | Measure-object).count -ne 1) {
		Write-Host "Multiple raw drives, the environment is out of scope.  Too many hard drives added!"
		Return
	}
	
	If((DiskSize_Cleanup $Disk.size) -eq $Drive_Size_LF){
		Write-Host "The Data drive is attacked and the correct size, proceeding."
	}
	Else{
		Write-Host "The Data drive $Drive_Letter_LF with a size of "
		return
	}

	Write-Host "Drive is ready for configuration, beginning the initialization process."
	#Suppresses pop-up windows
	Stop-Service -Name ShellHWDetection
	Initialize-Disk -number $Disk.Number -PartitionStyle MBR -PassThru |
		New-Partition -DriveLetter $Drive_Letter_LF.Substring(0,1) -UseMaximumSize |
		Format-Volume -NewFileSystemLabel "Application Data" -Confirm:$false
	Start-Service -Name ShellHWDetection
	Write-Host "Drive $Drive_Letter_LF has been configured and has a size of $Drive_Size_LF (GB)."
}


