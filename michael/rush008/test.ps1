
#we still have ssh to test









# we testing valid emails for now
$url = "https://rush08.cci.drexel.edu/user/password/reset"

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$resp = Invoke-WebRequest -Uri $url -WebSession $session
$search = $resp.Content -match 'name="_csrf"\s+value="([^"]+)"'
if (-not $search) {
    Write-Error "CSRF token not found."
    return
}

$token = $matches[1]

$headers = @{
    "Referer"        = $url
    "Origin"         = "https://rush08.cci.drexel.edu"
    "Content-Type"   = "application/json;charset=UTF-8"
    "Accept"         = "application/json, text/plain, */*"
    "User-Agent"     = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
}

$json = @"
{
  "_csrf": "$token",
  "email": "test@drexel.edu"
}
"@


try {
    $resp = Invoke-RestMethod -Uri $url `
    -Method Post `
    -WebSession $session `
    -Headers $headers `
    -Body $json
} catch {
    Write-Warning "`n[-] Request failed:"
    $_.Exception.Response.StatusCode.Value__
    $_.Exception.Message
}
