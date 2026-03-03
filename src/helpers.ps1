# helpers.ps1

function Get-Greeting {
    return "Hello from the helper function!"
}

function Invoke-CommandWithClaude {
    param (
        [string]$query
    )
    
    # Example of interacting with Claude, assuming you have a function to send the query
    $response = Get-ClaudeResponse -query $query
    return $response
}

# Fetch and aggregate the most active posts for a subreddit.
# Activity is measured as `score + num_comments` by default.
function Get-TopActivePosts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$Subreddit,
        [int]$Top = 10,
        [ValidateSet("hot", "new", "top", "rising")][string]$Sort = "hot",
        [string]$Time = "all"  # used when Sort is 'top' (hour, day, week, month, year, all)
    )

    $baseUrl = "https://www.reddit.com/r/$Subreddit/$Sort/.json?limit=100"
    if ($Sort -eq 'top' -and $Time) { $baseUrl += "&t=$Time" }

    $headers = @{ 'User-Agent' = 'powershell:reddit-summarize:v1.0 (by /u/yourusername)' }

    try {
        $resp = Invoke-RestMethod -Uri $baseUrl -Headers $headers -ErrorAction Stop
    }
    catch {
        throw "Failed to fetch subreddit '$Subreddit': $($_.Exception.Message)"
    }

    $posts = $resp.data.children | ForEach-Object {
        $p = $_.data
        [PSCustomObject]@{
            id           = $p.id
            title        = $p.title
            author       = $p.author
            url          = ("https://reddit.com" + $p.permalink)
            score        = $p.score
            num_comments = $p.num_comments
            created_utc  = [DateTimeOffset]::FromUnixTimeSeconds([int]$p.created_utc).DateTime
            engagement   = ($p.num_comments + $p.score)
        }
    }

    return $posts | Sort-Object -Property engagement -Descending | Select-Object -First $Top
}

# Example usage:
# . .\src\helpers.ps1
# Get-TopActivePosts -Subreddit "powershell" -Top 5 -Sort hot
