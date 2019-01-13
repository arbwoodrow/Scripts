Import-Module ActiveDirectory

  $date = $args[0]
  [string]$path = "C:\temp\NetworkReport" + $date + ".html"
  $computers= "computer1.domain.local"
  [string]$offlinecomputers = (": ")
  [string]$header = "The following report was run on $(get-date)"

 
Function Get-UpTime 
{ 
  Param ([string[]]$devices) 
  Write-Host "`n Getting uptime for $devices"
  Foreach ($device in $devices)  
   {  
		Try
		{
			 $os = Get-WmiObject -class win32_OperatingSystem -cn $device -ErrorAction Stop
			 $uptime = (get-date) - $os.converttodatetime($os.lastbootuptime)
			 New-Object psobject -Property @{Server=$device; 
			   Uptime = $uptime.ToString("dd") + " days"} 
		}
		Catch
		{
		Write-Host "    Could not retrieve uptime information from $device"
		Write-Host "        $_"
		$offlinecomputers = $offlinecomputers + $device + ", "
		Write-Host "        Current list of offline computers$offlinecomputers"
		}
    } #end foreach $device		
} #end function Get-Uptime 
 
Function Get-DiskSpace 
{ 
 Param ([string[]]$devices,[string[]]$drive) 
 Write-Host "`n Getting $drive drive information from $devices"
  Foreach ($device in $devices)  
   {  
     Try
		{Get-WmiObject -Class Win32_logicaldisk -cn $device -Filter "Name like '$drive%'" -ErrorAction Stop |
		Select-Object @{LABEL='Computer';EXPRESSION={$device}}, 
         @{LABEL='Disk';EXPRESSION={$_.name}},
         @{LABEL='Free Space (GB)';EXPRESSION={"{0:N2}" -f ($_.freespace/1GB)}},
		 @{LABEL='Size (GB)';EXPRESSION={"{0:N2}" -f ($_.size/1GB)}}
		}
	Catch
		{
		Write-Host "    Could not retrieve $drive drive information from $device"
		Write-Host "        $_"
		}
	
    } #end foreach $device 
} #end function Get-DiskSpace 
 
 
# Entry Point *** 
while($true)
{
$date = Get-Date
Write-Host "Current date-time: " + $date
Write-Host "This script will run in a loop until cancelled (press Ctrl+C), producing an HTML network report."

$header = "The following report was run on $(get-date)"
$offlinecomputers = ": "
"Total offline computers$offlinecomputers"

$ServerupTime = Get-UpTime -devices $servers | ConvertTo-Html -As Table -Fragment -PreContent " <h2>Server Uptime</h2> " | Out-String 
$ComputerupTime = Get-UpTime -devices $computers | Sort-Object 'Uptime' –Descending | ConvertTo-Html -As Table -Fragment -PreContent " <h2>PC Uptime</h2> " | Out-String


$serverCdisks = Get-DiskSpace -devices $servers -drive "C" | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Server system disk space</h2>"| Out-String   
$serverDdisks = Get-DiskSpace -devices $servers -drive "D" | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Server data disk space</h2>"| Out-String   
$computerCdisks = Get-DiskSpace -devices $computers -drive "C" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>PC system disk space</h2>"| Out-String   
$computerDdisks = Get-DiskSpace -devices $computers -drive "D" | Sort-Object {[int]$_.'Free Space (GB)'} | ConvertTo-Html -As Table -Fragment -PreContent "<h2>PC data disk space</h2>"| Out-String

"Total offline computers$offlinecomputers"

[string]$header = "The following report was run on $date"
ConvertTo-Html -Title "Network Summary" -Head '<link rel="stylesheet" type="text/css" href="http://SERVER/NetworkReport.css">'`
 -Body `
 '<div class="section"><h1>Imaginati Network Summary</h1>', $header, '</div>', `
 '<div id="server" class=section>', `
 '<div id="serveruptime" class="column">', $ServerupTime, '</div>', `
 '<div id="servercdisks" class="column">', $serverCdisks, '</div>', `
 '<div id="serverddisks" class="column">', $serverDdisks, '</div>', `
 '</div>', `
 '<div id="Offline PCs" class="section">', `
 '<div id="offlinepclist" class="column">', "Offline PCs$offlinecomputers", '</div>', `
 '</div>', `
  '<div id="PCs" class="section">', `
 '<div id="computeruptime" class="column">', $ComputerupTime, '</div>', `
 '<div id="computercdisks" class="column">', $computerCdisks, '</div>', `
 '<div id="computerddisks" class="column">', $computerDdisks, '</div>', `
 '</div>'
 > $path  
#Invoke-Item $path 
$date = Get-Date
Write-Host "`n Report finished at $date, and available at http://SERVER/NetworkReport.html Will run again in 10 minutes."
Start-Sleep -Seconds 360 #ten minutes
"`n"
}