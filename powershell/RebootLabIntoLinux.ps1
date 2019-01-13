#Script to reboot an OU from Windows into Linux
#This must be run from a domain Windows 7 PC with RSAT

#Set up prereqs and variables
Import-Module ActiveDirectory
$SearchBase = "OU=example,dc=domain,dc=local"

#Get list of labs
$OUs = Get-ADOrganizationalUnit -Filter * -Properties * -SearchBase $SearchBase -SearchScope OneLevel
Write-Host "`nPlease select an OU:"
Foreach ($OU in $OUs)
    {
    $Index = [array]::IndexOf($OUs, $OU)
    $OUName = $OUs[$Index].Name
    Write-Host "$Index for $OUName"
    } #end foreach $OU

#Ask user to select a lab by index number
$OUChoice = ""
While ($OUChoice -NotMatch "_") #All labs should have an underscore in the name e.g. L1_Mordor
{
$IndexChoice = ""
While ($IndexChoice -eq "") {$IndexChoice = Read-Host "`nType the number for the OU then press enter"}
$OUChoice = $OUs[$IndexChoice].DistinguishedName
$OUChoiceName = $OUs[$IndexChoice].Name
}

#Get list of computers from Active Directory
Write-Host "`nSearching for computers in $OUChoiceName...`n"
$Computers = Get-ADComputer -Filter * -Properties * -SearchBase $OUChoice #| Select DNSHostName
Write-Host "Found the following computers: $Computers.Name"


#Powershell remote commands work as domain admin, but not as local admin?
$User = Read-Host "`nPlease enter the name of your domain admin account"
$Username = "DOMAIN\$User"
$Pwd = Read-Host "Please enter your domain admin password" -AsSecureString
$Cred = New-Object System.Management.Automation.PSCredential -ArgumentList @($Username,$Pwd)

#Try the reboot command a few times just to make sure it sticks
Invoke-Command -cn $Computers.DNSHostName -Credential $Cred -ScriptBlock {Restart-Computer -Force}  -ErrorAction Continue
#Trying twice
Invoke-Command -cn $Computers.DNSHostName -Credential $Cred -ScriptBlock {Restart-Computer -Force}  -ErrorAction Continue
#Trying thrice
Invoke-Command -cn $Computers.DNSHostName -Credential $Cred -ScriptBlock {Restart-Computer -Force}  -ErrorAction Continue
Write-Host "Finished"
pause