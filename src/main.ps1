# main.ps1
Write-Host "Welcome to the Claude PowerShell Integration Example!"
Write-Host "Running main script..."

# Call a helper function
$greeting = Get-Greeting
Write-Host "Greeting from helper: $greeting"

# Interact with Claude (example)
# Assuming you've set up a Claude API call in claude_integration.ps1
$response = Get-ClaudeResponse -query "How can I use PowerShell with Claude?"
Write-Host "Claude's Response: $response"
