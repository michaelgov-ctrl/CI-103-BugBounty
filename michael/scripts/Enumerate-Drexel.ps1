$apiKey = "<key>"
$cx = "<id>"

$query = "drexel.edu -www.drexel.edu"
$encodedQuery = [uri]::EscapeDataString($query)

$results = @{}
$maxPages = 10  # max of 50 results, 10 per page

# Initial request to determine how many results are available
$url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$encodedQuery&start=1"

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    $totalResults = [int]$response.searchInformation.totalResults
    Write-Host "Total results found: $totalResults"

    $pagesToFetch = [math]::Min([math]::Ceiling($totalResults / 10), $maxPages)

    for ($i = 0; $i -lt $pagesToFetch; $i++) {
        $startPage = 1 + ($i * 10)
        $url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$encodedQuery&start=$startPage"

        try {
            $response = Invoke-RestMethod -Uri $url -Method Get
            if ($response.items) {
                foreach ($item in $response.items) {
                    $results[$item.displayLink] = $null
                }
            } else {
                Write-Host "No items found at start=$startPage"
            }
        } catch {
            Write-Host "Error on page starting at " $startPage ": " $_.Exception.Message
        }
    }
} catch {
    Write-Host "Error on page starting at " $startPage ": " $_.Exception.Message
}

$results.Keys | Sort-Object | Out-File .\subdomains.txt
$results.Keys | Sort-Object | Out-File .\subdomains.txt
