param (
    [string]$BaseURL = "https://www.techserv.drexel.edu/techserv"
)

# Ensure trailing slash is removed
$BaseURL = $BaseURL.TrimEnd("/")

function Test-RESTUsers {
    $url = "$BaseURL/wp-json/wp/v2/users"
    Write-Host "`n[*] Testing REST API user enumeration at: $url"
    try {
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -ErrorAction Stop
        Write-Host "[!] Unexpected success - Possible user enumeration vulnerability!"
        $response.Content | ConvertFrom-Json | Format-Table
    } catch {
        if ($_.Exception.Response.StatusCode -eq 401) {
            Write-Host "[+] REST API endpoint secured (401 Unauthorized)"
        } elseif ($_.Exception.Response.StatusCode -eq 403) {
            Write-Host "[+] REST API endpoint secured (403 Forbidden)"
        } else {
            Write-Host "[?] Unexpected response: $($_.Exception.Message)"
        }
    }
}

function Test-AuthorArchiveRedirect {
    Write-Host "`n[*] Testing author archive redirection:"
    for ($i = 1; $i -le 5; $i++) {
        $url = "$BaseURL/?author=$i"
        try {
            $response = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -UseBasicParsing -ErrorAction Stop
            Write-Host "[!] Author ID $i - Unexpected success"
        } catch {
            if ($_.Exception.Response.StatusCode -eq 301 -or $_.Exception.Response.StatusCode -eq 302) {
                $location = $_.Exception.Response.Headers["Location"]
                if ($location -match "/author/([^/]+)/?") {
                    $user = $matches[1]
                    Write-Host "[!] Author ID $i exposed username: $user"
                } else {
                    Write-Host "[+] Author ID $i - Redirect without username exposure"
                }
            } else {
                Write-Host "[+] Author ID $i - No redirect (status: $($_.Exception.Response.StatusCode))"
            }
        }
    }
}

function Test-LoginErrorLeak {
    $url = "$BaseURL/wp-login.php"
    Write-Host "`n[*] Testing login error messages for username validation:"

    $postParams = @{
        log = "likely_nonexistent_user_xyz123"
        pwd = "FakePassword123!"
        'wp-submit' = "Log In"
        redirect_to = "$BaseURL/wp-admin/"
    }

    $headers = @{
        "Content-Type" = "application/x-www-form-urlencoded"
    }

    try {
        $response = Invoke-WebRequest -Uri $url -Method POST -Body $postParams -Headers $headers -UseBasicParsing
        if ($response.Content -match "Invalid username") {
            Write-Host "[!] Login form reveals invalid usernames (leaky error messages)"
        } elseif ($response.Content -match "incorrect password") {
            Write-Host "[!] Login form reveals valid usernames (vulnerable to brute force)"
        } else {
            Write-Host "[+] Login form uses generic error messages (secure)"
        }
    } catch {
        Write-Host "[?] Error testing login form: $($_.Exception.Message)"
    }
}

# Run all tests
Test-RESTUsers
Test-AuthorArchiveRedirect
Test-LoginErrorLeak