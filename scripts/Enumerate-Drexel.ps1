
# https://developers.google.com/custom-search/v1/overview
$apiKey = "<key>"

# search engine id
$cx = "<id>"

# google site search: site:*.drexel.edu
$query = "site:*.drexel.edu"
$encodedQuery = [uri]::EscapeDataString($query)

$results = @{}
for ($startPage = 1; $startPage -le 101; $startPage += 10) {
    $url = "https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=$encodedQuery&start=$startPage"

    $response = Invoke-RestMethod -Uri $url -Method Get
    foreach ($item in $response.items) {
        $results[$item.displayLink] = $null
    }
}

$results.Keys | Sort-Object | Out-File .\subdomains.txt

