# Repository guidance for AI coding agents

This repository is a small PowerShell-based example that demonstrates calling a conversational model (Claude) from scripts. The guidance below is concise and actionable so an AI coding agent can be productive immediately.

1) Big picture
- **Type:** Small PowerShell script collection (no build system).
- **Components:** `src/main.ps1` (entry), `src/helpers.ps1` (utility functions), `src/claude_integration.ps1` (external API integration).
- **Data flow:** `main.ps1` calls helper functions (e.g. `Get-Greeting`) and `Get-ClaudeResponse` which sends HTTP requests to the Claude endpoint.
- **Why:** It's an example/demo project; keep changes minimal and prefer configuration via environment variables (secrets must not be committed).

2) Important files to reference
- `src/main.ps1` — entrypoint that demonstrates usage of helpers and the Claude integration.
- `src/helpers.ps1` — local utility functions and the pattern for exposing functionality as PowerShell functions.
- `src/claude_integration.ps1` — shows `Invoke-RestMethod` usage and a placeholder API key; update to use environment variables.

3) Developer workflows (concrete commands)
- Start an interactive PowerShell session and dot-source dependency scripts before running the entry script:

```powershell
pwsh
. .\src\helpers.ps1
. .\src\claude_integration.ps1
.\src\main.ps1
```

- To avoid hardcoding the API key, set an environment variable in the session before running:

```powershell
$env:CLAUDE_API_KEY = 'your-real-key-here'
# or for persistent Windows storage: setx CLAUDE_API_KEY "your-real-key-here"
```

4) Project-specific conventions & patterns
- PowerShell function naming uses PascalCase (e.g. `Get-Greeting`, `Get-ClaudeResponse`).
- Each script defines one or more functions; callers are expected to dot-source the file to import functions into the session.
- Error handling: `claude_integration.ps1` uses `try { } catch { }` and emits errors with `Write-Host` — preserve this style when adding similar integrations.

5) Integration points & dependencies
- The code calls an external Claude endpoint via `Invoke-RestMethod`. Replace the placeholder `your-api-key` with a runtime-provided secret (prefer `$env:CLAUDE_API_KEY`).
- The request body is JSON with keys `prompt` and `model` per the example in `claude_integration.ps1`.

6) What to change & where (concrete examples)
- Replace inline `$apiKey = "your-api-key"` with reading from `$env:CLAUDE_API_KEY` in `src/claude_integration.ps1`.
- When adding new features, follow the existing layout: implement functions in `src/*.ps1` and call them from `src/main.ps1`.

7) Constraints for suggestions
- Do not add secrets or keys to the repo. All code changes that reference credentials should default to environment variables.
- Keep changes small and reversible — this is a demo repo; prioritize clarity over heavy refactors.

If anything in this file is unclear or you'd like more detail (example tests, CI, or a secret-management pattern), tell me which area to expand. 
