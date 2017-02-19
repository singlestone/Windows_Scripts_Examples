if (!(Test-Path FAKECORP:)){
	New-PSDrive -Name FAKECORP -PSProvider ActiveDirectory -Server "ADSERVER.FAKECORP.adcmax.carmax.org" -Scope Global -root "//RootDSE/"
}

cd FAKECORP:	 
Get-ADUser -filter {Enabled -eq "False"} | Export-Csv C:\Users\9500026\Downloads\CSV\Disabled_FAKEUSERS.csv -notypeinformation 
cd c:
