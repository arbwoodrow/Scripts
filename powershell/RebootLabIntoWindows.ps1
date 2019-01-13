#Script to reboot an OU from Linux into Windows
#This must be run from a domain Windows 7 PC with RSAT and Putty

#Set up prereqs and variables
Import-Module ActiveDirectory
$SearchBase = "OU=eg,OU=example,dc=domain,dc=local"

#Get list of labs
$OUs = Get-ADOrganizationalUnit -Filter * -Properties * -SearchBase $SearchBase -SearchScope OneLevel
Write-Host "`nPlease select an OU"
Foreach ($OU in $OUs)
    {
    $Index = [array]::IndexOf($OUs, $OU)
    $OUName = $OUs[$Index].Name
    Write-Host "$Index for $OUName"
    } #end foreach $OU

#Ask user to select a lab by index number
$OUChoice = ""
While ($OUChoice -NotMatch "_")
{
$IndexChoice = ""
While ($IndexChoice -eq "") {$IndexChoice = Read-Host "`nType the number for the OU then press enter"}
$OUChoice = $OUs[$IndexChoice].DistinguishedName
$OUChoiceName = $OUs[$IndexChoice].Name
}

#Get list of computers
Write-Host "`nSearching for computers in $OUChoiceName...`n"
$Computers = Get-ADComputer -Filter * -Properties * -SearchBase $OUChoice
Write-Host "Found the following computers: $Computers.Name"

#Need the root password to send to the PCs
$RootPwd = Read-Host "`nPlease enter the local root password for this OU" -AsSecureString
$RootPwdTxt = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPwd))

#Now go through each computer, look for an IP address in Qube, then send reboot command
Foreach ($Computer in $Computers)
    {
    $Index = [array]::IndexOf($Computers, $Computer)
    $PCName = $Computers[$Index].Name
    $Hosts = "" #Array of hosts and details - DNS lookup not working in this situation
	#Grab the line of the array for this PC
    [string]$PCInfo = $Hosts -match "$PCName"
    $IPAddress = ""
	#Just get the bit of the array that we want
    $IPAddress = $PCInfo.split(' ',[System.StringSplitOptions]::RemoveEmptyEntries)[2]
    If ($IPAddress -NotMatch ".") {Write-Host "$PCName not found in array"}
    Else
        {
        "Attempting to send command to $PCName on $IPAddress..."
        #C:\"Program Files"\PuTTY\plink.exe
        #Start by echoing "y" then send an exit command to get past first time connection issues
        echo y | plink -ssh $IPAddress -l root -pw $RootPwdTxt "exit"
        #Set grub to reboot into 3rd menu choice (index 2) which should be Windows
        plink -ssh $IPAddress -batch -l root -pw $RootPwdTxt "sudo grub2-reboot 2"
        #Then send reboot command
        plink -ssh $IPAddress -batch -l root -pw $RootPwdTxt "sudo reboot now"
        }
    } #end foreach $Computer
Write-Host "Finished"