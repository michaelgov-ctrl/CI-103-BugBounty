
$targets = Get-Content -Path ..\subdomains.txt -ErrorAction Stop
$targets | ForEach-Object { sudo nmap -p 1-65535 $_ -A -v -oN ("./scans/$_-nmap.txt") }