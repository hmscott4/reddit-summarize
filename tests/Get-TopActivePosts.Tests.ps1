Describe "Get-TopActivePosts" {
    BeforeAll {
        . "$PSScriptRoot\..\src\helpers.ps1"

        $mockResp = @{ 
            data = @{ 
                children = @( 
                    @{ data = @{ id = 'a1'; title = 'Post A'; author = 'user1'; permalink = '/r/test/a1'; score = 10; num_comments = 5; created_utc = 1609459200 } },
                    @{ data = @{ id = 'b2'; title = 'Post B'; author = 'user2'; permalink = '/r/test/b2'; score = 3; num_comments = 20; created_utc = 1609459300 } },
                    @{ data = @{ id = 'c3'; title = 'Post C'; author = 'user3'; permalink = '/r/test/c3'; score = 8; num_comments = 2; created_utc = 1609459400 } }
                )
            }
        }

        $mockObject = $mockResp | ConvertTo-Json -Depth 5 | ConvertFrom-Json

        Mock -CommandName Invoke-RestMethod -MockWith { return $mockObject }
    }

    It "returns the top N posts ordered by engagement (score + comments)" {
        $result = Get-TopActivePosts -Subreddit 'test' -Top 2 -Sort hot
        $result.Count | Should -Be 2
        # b2 has engagement 23, a1 has 15, c3 has 10
        $result[0].id | Should -Be 'b2'
        $result[1].id | Should -Be 'a1'
    }
}

# To run locally:
# pwsh -NoProfile -Command "if (-not (Get-Module -ListAvailable -Name Pester)) { Install-Module Pester -Force -Scope CurrentUser -AllowClobber }; Invoke-Pester -Script tests/Get-TopActivePosts.Tests.ps1"
