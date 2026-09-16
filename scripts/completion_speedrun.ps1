param(
  [string]$MinimumRoot = ".\\artifacts\\flutterflow_minimum",
  [string]$Phase1Root = ".\\artifacts\\flutterflow_phase1"
)

$ErrorActionPreference = "Stop"

function Test-ToolAvailable {
  param([Parameter(Mandatory = $true)][string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-OptionalScript {
  param(
    [Parameter(Mandatory = $true)][string]$Label,
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][scriptblock]$Runner
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    Write-Host ("[skip] {0}: missing script {1}" -f $Label, $Path) -ForegroundColor Yellow
    return
  }

  Write-Host ""
  Write-Host ("=== {0} ===" -f $Label) -ForegroundColor Cyan
  & $Runner $Path
}

Write-Host "KnockQuest completion speedrun" -ForegroundColor Green
Write-Host ""

$gitAvailable = Test-ToolAvailable -Name "git"
$flutterAvailable = Test-ToolAvailable -Name "flutter"

Write-Host ("git cli: {0}" -f ($(if ($gitAvailable) { "available" } else { "missing" })))
Write-Host ("flutter cli: {0}" -f ($(if ($flutterAvailable) { "available" } else { "missing" })))

if (-not $gitAvailable -or -not $flutterAvailable) {
  Write-Host ""
  Write-Host "blocking setup:" -ForegroundColor Yellow
  if (-not $gitAvailable) {
    Write-Host "- git is not on PATH for this shell"
  }
  if (-not $flutterAvailable) {
    Write-Host "- flutter is not on PATH for this shell"
  }
}

$scriptRoot = $PSScriptRoot

Invoke-OptionalScript `
  -Label "exact minimum required capture" `
  -Path (Join-Path $scriptRoot "summarize_flutterflow_missing_exact.ps1") `
  -Runner {
    param($scriptPath)
    & $scriptPath -Root $MinimumRoot
  }

Invoke-OptionalScript `
  -Label "minimum capture pack status" `
  -Path (Join-Path $scriptRoot "summarize_flutterflow_minimum_capture.ps1") `
  -Runner {
    param($scriptPath)
    & $scriptPath -Root $MinimumRoot -ShowMissing
  }

Invoke-OptionalScript `
  -Label "phase1 capture pack status" `
  -Path (Join-Path $scriptRoot "summarize_flutterflow_artifacts.ps1") `
  -Runner {
    param($scriptPath)
    & $scriptPath -Root $Phase1Root -ShowMissing
  }

Write-Host ""
Write-Host "next action order:" -ForegroundColor Green
Write-Host "1) keep exact minimum at 8/8"
Write-Host "2) push phase1 captures page-by-page based on missing list"
Write-Host "3) run flutter analyze and flutter test once flutter cli is available"
