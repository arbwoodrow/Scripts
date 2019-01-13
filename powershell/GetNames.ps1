#Looks at a list of usernames, returns with firstname and lastname

Import-Module ActiveDirectory
$users = ("example","person")
$currentdir = Split-Path $myInvocation.MyCommand.Path

Function Get-Names
{ 
  Param ([string[]]$users) 
  Write-Host "" | Export-Csv -Path $currentdir\users.csv
  Foreach ($user in $users)  
   { 
		Try	{
			 $userdata = Get-ADUser $user
			 Write-Host $userdata.GivenName $userdata.Surname | Export-Csv -Path $currentdir\users.csv -Append
		}
		Catch {
			Write-Host "    Could not find $user"
			}
		}
    } #end foreach $user	
} #end function

Get-Names  -users $users
"`n"
pause