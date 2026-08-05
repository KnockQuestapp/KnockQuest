param(
  [string]$SourceRoot = ".\\lib",
  [string]$DocsRoot = "."
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourceRoot)) {
  throw "Source root not found: $SourceRoot"
}

function Find-LibMatches {
  param(
    [Parameter(Mandatory = $true)][string]$Pattern
  )

  Get-ChildItem -Path $SourceRoot -Recurse -File -Include *.dart |
    Select-String -Pattern $Pattern -CaseSensitive:$false
}

function Find-FileMatches {
  param(
    [Parameter(Mandatory = $true)][string[]]$Paths,
    [Parameter(Mandatory = $true)][string]$Pattern
  )

  $results = @()
  foreach ($path in $Paths) {
    if (Test-Path -LiteralPath $path) {
      $results += Select-String -Path $path -Pattern $Pattern -CaseSensitive:$false
    }
  }

  return $results
}

Write-Host "Running GitHub-exclusive codebase checks..." -ForegroundColor Cyan

$legacyBuilderMentions = Find-LibMatches -Pattern "flutterflow"
if ($legacyBuilderMentions) {
  Write-Host "Found forbidden FlutterFlow references in app source:" -ForegroundColor Red
  $legacyBuilderMentions | ForEach-Object {
    Write-Host ("- {0}:{1}" -f $_.Path, $_.LineNumber)
  }
  throw "GitHub-exclusive check failed: remove FlutterFlow references from lib/."
}

$deliverySurfaceMentions = Find-FileMatches -Paths @(
  (Join-Path $DocsRoot "README.md"),
  (Join-Path $DocsRoot ".github\\pull_request_template.md"),
  (Join-Path $DocsRoot ".github\\workflows\\blank.yml"),
  (Join-Path $DocsRoot ".github\\workflows\\release_web_artifact.yml")
) -Pattern "flutterflow"

if ($deliverySurfaceMentions) {
  Write-Host "Found forbidden FlutterFlow references in GitHub delivery surfaces:" -ForegroundColor Red
  $deliverySurfaceMentions | ForEach-Object {
    Write-Host ("- {0}:{1}" -f $_.Path, $_.LineNumber)
  }
  throw "GitHub-exclusive check failed: remove FlutterFlow references from docs/workflows."
}

$placeholderUsages = Get-ChildItem -Path $SourceRoot -Recurse -File -Include *.dart |
  Select-String -Pattern "UnderConstructionPage" -CaseSensitive:$false

if ($placeholderUsages) {
  $externalUsages = $placeholderUsages |
    Where-Object { $_.Path -notlike "*under_construction_page.dart" }

  if ($externalUsages) {
    Write-Host "Found route/page usages still pointing to placeholder implementation:" -ForegroundColor Red
    $externalUsages | ForEach-Object {
      Write-Host ("- {0}:{1}" -f $_.Path, $_.LineNumber)
    }
    throw "GitHub-exclusive check failed: remove UnderConstructionPage usages from runtime routes."
  }
}

Write-Host "GitHub-exclusive checks passed." -ForegroundColor Green
