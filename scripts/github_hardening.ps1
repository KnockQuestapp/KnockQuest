param(
  [string]$Owner = "KnockQuestapp",
  [string]$Repo = "KnockQuest",
  [string]$Branch = "main"
)

$ErrorActionPreference = "Stop"
$gh = "C:\Program Files\GitHub CLI\gh.exe"

if (-not (Test-Path $gh)) {
  throw "GitHub CLI not found at $gh"
}

& $gh auth status | Out-Null

$protectionBody = @{
  required_status_checks = @{
    strict = $true
    contexts = @("verify")
  }
  enforce_admins = $true
  required_pull_request_reviews = @{
    dismiss_stale_reviews = $true
    require_code_owner_reviews = $false
    required_approving_review_count = 1
  }
  restrictions = $null
  required_linear_history = $false
  allow_force_pushes = $false
  allow_deletions = $false
  block_creations = $false
  required_conversation_resolution = $true
  lock_branch = $false
  allow_fork_syncing = $true
} | ConvertTo-Json -Depth 8 -Compress

$tmp = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tmp -Value $protectionBody -NoNewline -Encoding UTF8
& $gh api --method PUT "/repos/$Owner/$Repo/branches/$Branch/protection" --input $tmp | Out-Null
Remove-Item $tmp -Force

$labels = @(
  @{ name = "type: bug"; color = "d73a4a"; description = "A defect or regression" },
  @{ name = "type: feature"; color = "0e8a16"; description = "A new feature request" },
  @{ name = "type: chore"; color = "5319e7"; description = "Maintenance or technical housekeeping" },
  @{ name = "type: docs"; color = "1d76db"; description = "Documentation update" },
  @{ name = "type: security"; color = "b60205"; description = "Security-related work" },
  @{ name = "priority: p0"; color = "b60205"; description = "Critical and urgent" },
  @{ name = "priority: p1"; color = "d93f0b"; description = "High priority" },
  @{ name = "priority: p2"; color = "fbca04"; description = "Medium priority" },
  @{ name = "priority: p3"; color = "c2e0c6"; description = "Low priority" },
  @{ name = "area: auth"; color = "bfdadc"; description = "Authentication and access control" },
  @{ name = "area: maps"; color = "bfd4f2"; description = "Mapping and routing" },
  @{ name = "area: quests"; color = "c5def5"; description = "Quest and mission features" },
  @{ name = "area: ci"; color = "7057ff"; description = "Build and automation" },
  @{ name = "area: docs"; color = "0366d6"; description = "Docs and process" },
  @{ name = "status: needs-triage"; color = "ededed"; description = "Needs initial triage" },
  @{ name = "status: blocked"; color = "000000"; description = "Cannot proceed due to dependency" },
  @{ name = "status: in-progress"; color = "fbca04"; description = "Actively being worked" },
  @{ name = "status: ready-for-review"; color = "0e8a16"; description = "Ready for review and verification" }
)

foreach ($label in $labels) {
  $name = $label.name
  $color = $label.color
  $description = $label.description

  $create = & $gh api --method POST "/repos/$Owner/$Repo/labels" -f "name=$name" -f "color=$color" -f "description=$description" 2>$null
  if ($LASTEXITCODE -ne 0) {
    & $gh api --method PATCH "/repos/$Owner/$Repo/labels/$([uri]::EscapeDataString($name))" -f "new_name=$name" -f "color=$color" -f "description=$description" | Out-Null
  } else {
    $create | Out-Null
  }
}

Write-Output "GitHub hardening completed for $Owner/$Repo on branch $Branch"
