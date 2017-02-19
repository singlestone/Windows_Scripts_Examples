# PowerCLI Frunctions for provisioning a template.

# Connects to vsphere and adds PowerCLI snapping to the Powershell instance.
# This should be the first function called with doing anything with PowerCLI

 # Works 6/5/2015
Function Initialize_vSphere_Connection() {
	param(
		[string]$vSphere_IC,
        [object]$mycredentials_IC
    )
	Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Checking PowerCLI functionality."

	Connect-VIServer `
		-Server $vSphere_IC `
		-Credential $mycredentials_IC
}

# Works - 6/4/2015
Function Get_Datastore_Stats() {
	param(
		[string]$myDatastore
	)

    $datastores_Stat = get-datastore $myDatastore | 
        get-view |
        select -expandproperty summary |
		select  @{N="capacity"; E={[math]::round($_.Capacity/1GB,2)}}, `
				@{N="freespace"; E={[math]::round($_.FreeSpace/1GB,2)}}, `
				@{N="provisioned"; E={[math]::round(($_.Capacity - $_.FreeSpace + $_.Uncommitted)/1GB,2)}}
	
	   return $datastores_Stat
    }

# Works - 6/4/2015
Function Confirm_Datastore_availability() {
	param(
		[string]$myTemplate,
		[string]$myDatastoreCluster,
		[INT]$MyNew_Drive_Size
	)

	Try {
		$Size_needed = (Get-HardDisk -Template "2012R2DC").CapacityGB
		$Size_available =  (Get_Datastore_Stats $myDatastoreCluster).freespace
	}
	Catch {
		Write-Host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Error Confirming Datastore availability!"
		Return
	}

	if(($Size_needed + $MyNew_Drive_Size) -gt $Size_available){
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Not enough free space to deploy the VM!"
		return $false
	}	
	else{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Confirmed available space, proceeding."
		return $true
	}
}

# Works - 6/23/2015
Function Deploy_Template() {
	param(
		[string]$myVMName,
		[string]$myTemplate,
		[string]$myDatastoreCluster,
		[string]$myResourcePool,
		[INT]$MyNew_Drive_Size
	)	

	if(!(Confirm_Datastore_availability $myTemplate $myDatastoreCluster $MyNew_Drive_Size)){
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Datastore test failed, aborting....."
		Exit
	}

	Else{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Initiating template deployment."

		## This command creates the VM	
		$task = New-VM  -Name $myVMName `
					-Template $myTemplate `
					-Datastore $myDatastoreCluster `
					-ResourcePool $myResourcePool `
					-RunAsync
					
		Write-host $((Get-Date).ToString('MMyyyyddhhmmss')) : "Template: myTemplate being deployed to Datastore  $myDatastoreCluster......"
		
		while($task.ExtensionData.Info.State -eq "running"){
			sleep 1
			$task.ExtensionData.UpdateViewData('Info.State')
		}
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Template deployed, $myVMName has been provisioned."
		#Configure_VM_NIC 
	}
}

Function Configure_VM_First_Boot() {
	param(
		[string]$myVMName,
		[string]$myRam,
		[string]$myNUM_CPU,
		[string]$New_Drive_Size,
		[string]$NICAPT,
		[string]$NetworkLB 
	)	
	
	Set-VM `
		-VM $myVMName `
		-MemoryMB $myRam `
		-NumCpu $myNUM_CPU `
		-Confirm:$false

	Add_VM_Disk `
		$myVMName `
		$New_Drive_Size
	
	Configure_VM_NIC `
		$myVMName `
		$NICAPT `
		$NetworkLB 
	
	Turn_On_VM `
		$myVMName
}

Function Add_VM_Disk() {
	param(
		[string]$myVMName,
		[string]$New_Drive_Size
	)	
	
	New-HardDisk `
		-VM $myVMName `
		-CapacityGB $New_Drive_Size `
		-StorageFormat Thin `
		-Confirm:$false
}

#Works - 6/23/2015
Function Configure_VM_NIC() {
	param(
		[string]$MyServer,
		[string]$Nic1,
		[string]$MySelected_Network
	)

	Get-VM $MyServer | `
		Get-NetworkAdapter `
			-Name $Nic1 | `
				Set-NetworkAdapter `
					-NetworkName $mySelected_Network `
					-StartConnected:$false `
					-Confirm:$false					
}

Function Turn_On_VM() {
	param(
		[string]$myVMName
	)
	
	Start-vm -VM $myVMName -runAsync
	Start-Sleep -Seconds 10;

	do{
		Write-host "$((Get-Date).ToString('MMyyyyddhhmmss')) : Waiting 5 Seconds.... $toolsStatus"
		$vmstat = get-vm $myVMName
		$vmstat  | `
			Get-VMQuestion | `
			Set-VMQuestion `
				-DefaultOption `
				-confirm:$false;
		Start-Sleep `
			-Seconds 5;
		$toolsStatus = $vmstat.extensionData.Guest.ToolsStatus;
	}while($toolsStatus -ne "toolsOk");
}