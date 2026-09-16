param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum",
  [string]$ProjectUrl = "https://app.flutterflow.io/project/knock-quest-ceh253",
  [int]$OpenDelaySeconds = 3,
  [switch]$Force,
  [switch]$NoOpen
)

$ErrorActionPreference = "Stop"

if ([Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
  throw "Run this wrapper in STA: powershell.exe -STA -ExecutionPolicy Bypass -File .\\scripts\\run_flutterflow_fastlane.ps1"
}

$captureScript = Join-Path $PSScriptRoot "capture_flutterflow_missing_autopilot.ps1"
$summaryScript = Join-Path $PSScriptRoot "summarize_flutterflow_missing_exact.ps1"

if (-not (Test-Path -LiteralPath $captureScript)) {
  throw "Missing script: $captureScript"
}

if (-not (Test-Path -LiteralPath $summaryScript)) {
  throw "Missing script: $summaryScript"
}

& $captureScript `
  -Root $Root `
  -ProjectUrl $ProjectUrl `
  -OpenDelaySeconds $OpenDelaySeconds `
  -Force:$Force `
  -NoOpen:$NoOpen

Write-Host ""
Write-Host "Exact status after capture run:"
& $summaryScript -Root $Root
