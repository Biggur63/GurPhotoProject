param(
    [string]$Message = "Update project",
    [string]$Repo = "Biggur63/GurPhotoProject",
    [string]$Branch = "main",
    [string]$SshConfig = "$env:USERPROFILE\.ssh\config",
    [switch]$SkipHugoCheck
)

$ErrorActionPreference = "Stop"

function Invoke-Git {
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @args 2>&1
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($code -ne 0) {
        throw "git $($args -join ' ') failed:`n$($output -join [Environment]::NewLine)"
    }
    return $output
}

function Get-GitHubToken {
    $credential = @("protocol=https", "host=github.com", "") | git credential fill
    $token = $credential |
        Where-Object { $_ -like "password=*" } |
        ForEach-Object { $_.Substring(9) } |
        Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($token)) {
        throw "GitHub token was not found in the git credential helper."
    }

    return $token
}

function Invoke-GitHubApi {
    param(
        [string]$Method,
        [string]$Uri,
        [object]$Body = $null
    )

    $headers = @{
        Authorization          = "Bearer $script:GitHubToken"
        Accept                 = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2022-11-28"
        "User-Agent"           = "GurPhotoProject-save-script"
    }

    if ($null -eq $Body) {
        return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
    }

    return Invoke-RestMethod `
        -Method $Method `
        -Uri $Uri `
        -Headers $headers `
        -ContentType "application/json" `
        -Body ($Body | ConvertTo-Json -Depth 8 -Compress)
}

function Test-HugoPortableConfig {
    $configPath = Join-Path (Get-Location) "hugo.toml"
    if (-not (Test-Path -LiteralPath $configPath)) {
        return
    }

    $config = Get-Content -LiteralPath $configPath -Raw
    if ($config -match "(?m)^\s*cacheDir\s*=\s*['""][A-Za-z]:[\\/][^'""]*['""]") {
        throw "hugo.toml contains an absolute Windows cacheDir. Remove it and pass --cacheDir only in local/CI commands."
    }

    if (-not $SkipHugoCheck) {
        $cacheDir = Join-Path (Get-Location) ".hugo_cache\save-check"
        & hugo config --cacheDir $cacheDir | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "Hugo config check failed."
        }
    }
}

function Get-ChangedFilesFromHead {
    $rows = Invoke-Git diff-tree --no-commit-id --name-status -r HEAD
    $items = @()

    foreach ($row in $rows) {
        if ([string]::IsNullOrWhiteSpace($row)) {
            continue
        }

        $parts = $row -split "`t"
        $status = $parts[0]
        $path = $parts[-1]

        if ($status.StartsWith("R") -and $parts.Count -ge 3) {
            $items += [pscustomobject]@{ Status = "D"; Path = $parts[1] }
            $items += [pscustomobject]@{ Status = "A"; Path = $parts[2] }
            continue
        }

        $items += [pscustomobject]@{ Status = $status.Substring(0, 1); Path = $path }
    }

    return $items
}

function Push-WithGitHubApiFallback {
    $script:GitHubToken = Get-GitHubToken

    $remoteRef = Invoke-GitHubApi `
        -Method Get `
        -Uri "https://api.github.com/repos/$Repo/git/ref/heads/$Branch"
    $parentSha = $remoteRef.object.sha

    $remoteCommit = Invoke-GitHubApi `
        -Method Get `
        -Uri "https://api.github.com/repos/$Repo/git/commits/$parentSha"

    $treeEntries = @()
    foreach ($item in Get-ChangedFilesFromHead) {
        $apiPath = ($item.Path -replace "\\", "/")

        if ($item.Status -eq "D") {
            $treeEntries += @{
                path = $apiPath
                mode = "100644"
                type = "blob"
                sha  = $null
            }
            continue
        }

        $fullPath = Join-Path (Get-Location) $item.Path
        if (-not (Test-Path -LiteralPath $fullPath)) {
            continue
        }

        $bytes = [IO.File]::ReadAllBytes($fullPath)
        $blob = Invoke-GitHubApi `
            -Method Post `
            -Uri "https://api.github.com/repos/$Repo/git/blobs" `
            -Body @{
                content  = [Convert]::ToBase64String($bytes)
                encoding = "base64"
            }

        $treeEntries += @{
            path = $apiPath
            mode = "100644"
            type = "blob"
            sha  = $blob.sha
        }
    }

    if ($treeEntries.Count -eq 0) {
        Write-Host "No changed files in HEAD to send through GitHub API."
        return
    }

    $newTree = Invoke-GitHubApi `
        -Method Post `
        -Uri "https://api.github.com/repos/$Repo/git/trees" `
        -Body @{
            base_tree = $remoteCommit.tree.sha
            tree      = $treeEntries
        }

    $commitMessage = (Invoke-Git log -1 --pretty=%B) -join [Environment]::NewLine
    $authorName = (Invoke-Git log -1 --pretty=%an)[0]
    $authorEmail = (Invoke-Git log -1 --pretty=%ae)[0]
    $now = [DateTimeOffset]::Now.ToString("yyyy-MM-ddTHH:mm:ssK")
    $person = @{
        name  = $authorName
        email = $authorEmail
        date  = $now
    }

    $newCommit = Invoke-GitHubApi `
        -Method Post `
        -Uri "https://api.github.com/repos/$Repo/git/commits" `
        -Body @{
            message   = $commitMessage
            tree      = $newTree.sha
            parents   = @($parentSha)
            author    = $person
            committer = $person
        }

    Invoke-GitHubApi `
        -Method Patch `
        -Uri "https://api.github.com/repos/$Repo/git/refs/heads/$Branch" `
        -Body @{
            sha   = $newCommit.sha
            force = $false
        } | Out-Null

    Write-Host "Saved through GitHub API: $($newCommit.sha)"
    Write-Host "Note: local git refs may still look ahead until normal git network access returns."
}

Test-HugoPortableConfig

Invoke-Git add -A | Out-Null
& git diff --cached --quiet
$hasStagedChanges = $LASTEXITCODE -ne 0

if ($hasStagedChanges) {
    Invoke-Git commit --no-gpg-sign -m $Message | Write-Host
}
else {
    Write-Host "No new file changes to commit."
}

$sshCommand = "ssh -F $SshConfig"
try {
    Invoke-Git -c "core.sshCommand=$sshCommand" push origin $Branch | Write-Host
    Write-Host "Saved through git push."
}
catch {
    Write-Host "git push failed, switching to GitHub API fallback."
    Write-Host $_.Exception.Message
    Push-WithGitHubApiFallback
}
