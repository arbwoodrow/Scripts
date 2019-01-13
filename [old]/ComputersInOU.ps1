#Script that returns a list of computers in a Lab according to Active Directory

Import-Module ActiveDirectory
$SearchBase = "OU=eg,OU=example,dc=pcltmp,dc=local"

$OUs = Get-ADOrganizationalUnit -Filter * -Properties * -SearchBase $SearchBase -SearchScope OneLevel

Write-Host "`nPlease select a lab:"
Foreach ($OU in $OUs)
    {
    $Index = [array]::IndexOf($OUs, $OU)
    $OUName = $OUs[$Index].Name
    Write-Host "$Index for $OUName"
    } #end foreach $OU


$OUChoice = ""
While ($OUChoice -NotMatch "_")
{
$IndexChoice = ""
While ($IndexChoice -eq "") {$IndexChoice = Read-Host "`nType the number for the OU then press enter"}
$OUChoice = $OUs[$IndexChoice].DistinguishedName
$OUChoiceName = $OUs[$IndexChoice].Name
}

Write-Host "`nGetting list of computers in $OUChoiceName...`n"

$Computers = Get-ADComputer -Filter * -Properties * -SearchBase $OUChoice
Foreach ($Computer in $Computers)
    {
    $Index = [array]::IndexOf($Computers, $Computer)
    $ComputerName = $Computers[$Index].Name
    $ComputerFQDN = $Computers[$Index].DNSHostName
    Write-Host "$Index - $ComputerName - $ComputerFQDN"
    } #end foreach $OU