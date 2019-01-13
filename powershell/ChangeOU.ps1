#Takes an array of computers, looks up their DistinguishedName in AD, then moves them to $TargetPath

Import-Module ActiveDirectory
$computers= ("computer1","computer2")
$targetpath = "OU=eg,OU=example,DC=domain,DC=local"

Function Move-PC 
{ 
  Param ([string[]]$devices) 
  Write-Host "`n Trying to move $devices to new OU"
  Foreach ($device in $devices)  
   {  
		"`n"
		Try
		{
			 $DN = Get-ADComputer $device
			 "Trying to move $DN"
			 Move-ADObject -Identity $DN.DistinguishedName -TargetPath $targetpath
		}
		Catch
		{
		Write-Host "    Something went wrong finding or moving $device!"
		Write-Host "        $_"
		}
    } #end foreach $device		
} #end function Move-PC 

Move-PC  -devices $computers 
"`n"
pause