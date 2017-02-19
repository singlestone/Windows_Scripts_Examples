# PowerCLI Frunctions for provisioning a template.

Function Confirm_Datastore_availability() {

	param(
		[string]$myTemplate,
		[string]$myDatastoreCluster,
		[INT]$MyNew_Drive_Size
	)

	$Size_needed = Get-HardDisk -Template $myVMName
	$Size_available =  Get-Datastore [math]::Round($info.Capacity - $info.Provisioned,2) 
	
	if(($Size_needed + $MyNew_Drive_Size) -lt $Size_available){
		Write-host "Not enough free space to deploy the VM!"
		return $false
	}	
	else{
		Write-host "Confirmed available space, proceeding."
		return $true
	}
}

Function Deploy_Template() {
	param(
		[string]$myVMName,
		[string]$myTemplate,
		[string]$myDatastoreCluster,
		[INT]$MyNew_Drive_Size
	)	

	if !(Confirm_Datastore_availability $myTemplate $myDatastoreCluster $MyNew_Drive_Size){
		Write-host "Datastore test failed, aborting....."
		Exit
	}

	Else{
		Write-host "Initiating template deployment."
		## This command creates the VM	
		
		$status = New-VM `
					-Name myVMName `
					-Template $myTemplate `
					-Datastore $myDatastoreCluster `
					-RunAsync 
					
		Write-host "Template: myTemplate being deployed to Datastore  $myDatastoreCluster......"
		
		while($task.ExtensionData.Info.State -eq "running"){
			sleep 1
			$task.ExtensionData.UpdateViewData('Info.State')
		}
		Write-host "Template deployed, $myVMName has been provisioned."
	}
}

Function Configure_VM_First_Boot() {

	param(
		[string]$myVMName,
		[string]$myRam,
		[string]$myNUM_CPU,
		[string]$New_Drive_Size
	)	
	
	Set-VM -VM $myVMName -MemoryMB $myRam -NumCpu $myNUM_CPU

	New-HardDisk `
		-VM $myVMName `
		-CapacityGB $New_Drive_Size `
		-StorageFormat Thin

	
}

Function Configure_VM_NIC() {

	param(
		[string]$Nic1,
		[string]$mySelected_Network
	)

	Set-NetworkAdapter `
					-NetworkAdapter ]$Nic1 `
					-NetworkName $mySelected_Network `
					-StartConnected:$true `
					-Connected:$true					
}

Invoke-VMScript `
	-VM VM `
	-GuestUser administrator `
	-GuestPassword pass2 `
	-ScriptText "dir" 


	
Function Set-WinVMIP ($VM, $HC, $GC, $IP, $SNM, $GW){
 $netsh = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Connection"" static $IP $SNM $GW 1"
 Write-Host "Setting IP address for $VM..."
 Invoke-VMScript -VM $VM -HostCredential $HC -GuestCredential $GC -ScriptType bat -ScriptText $netsh
 Write-Host "Setting IP address completed."
}
 
Connect-VIServer MYvCenter
 
$VM = Get-VM ( Read-Host "Enter VM name" )
$ESXHost = $VM | Get-VMHost
$HostCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter ESX host credentials for $ESXHost", "root", "")
$GuestCred = $Host.UI.PromptForCredential("Please enter credentials", "Enter Guest credentials for $VM", "", "")
 
$IP = "192.168.0.81"
$SNM = "255.255.255.0"
$GW = "192.168.0.1"
 
Set-WinVMIP $VM $HostCred $GuestCred $IP $SNM $GW
	