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
