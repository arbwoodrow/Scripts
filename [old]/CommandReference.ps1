# To launch a script from command line
powershell.exe -ExecutionPolicy Bypass .\ScriptDirectory\ScriptName.ps1

# Formatting and selecting
Command | Format-Table Variable1,Variable2,Variable3 # Performs command and outputs only the chosen variables in a readable table
"`r" # Carriage return

# Feedback and reporting
Write-Host "Any text here" # Write something straight to the screen for debugging
echo Command # echo is an alias for Write-Output, which writes to the Success output stream

# Logic
Start-sleep X # Where X is the number of seconds to wait
# Foreach loop
Foreach ($item in $list)
    {
    echo $item.Attribute
    Try
        {
        Write-Host "Attempting command"
        Command -ErrorAction Stop
        Write-Host "Command succeeded!"
        }
    Catch
        {
        Write-Host "Command failed!"
        }
    # Or go with an IF statement instead
    Command
    $result = $?
    If ($result -eq "SuccessParameter")
        {Write-Host "Command succeeded!"}
    Else
        {Write-Host "Command failed :-("}
} #end foreach $device

# Powershell: Active Directory commands
import-module ActiveDirectory
Get-ADComputer -Filter * -Properties * -SearchBase 'OU=smallest,OU=biggest,dc=example,dc=local'
