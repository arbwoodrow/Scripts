#Takes $Username, looks up group membership, exports list to CSV in current directory
$Username = Read-Host "Please enter the username you want to lookup: "
Get-ADPrincipalGroupMembership $Username | select name
$Groups = Get-ADPrincipalGroupMembership $Username | select name
$Groups | Export-Csv groups.csv
Write-Host "`nSaved to groups.csv in working directory"
pause