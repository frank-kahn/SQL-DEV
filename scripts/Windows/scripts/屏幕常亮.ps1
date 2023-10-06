$shell = New-Object -ComObject Wscript.Shell
$key = "{ScrollLock}"
for($x=1; $x -lt 1440; $x=$x+1)
{
    $time =Get-Date
	Write-Output "$time Run sendkeys : $key"
	$shell.sendkeys($key)
	Start-Sleep -Seconds 60
}