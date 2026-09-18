$ErrorActionPreference = "Stop"

function Assert-Command {
  param([Parameter(Mandatory = $true)][string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "$Name is not available on PATH."
  }
}

function Assert-LastExitCode {
  param([Parameter(Mandatory = $true)][string]$Step)
  if ($LASTEXITCODE -ne 0) {
    throw "$Step failed with exit code $LASTEXITCODE."
  }
}

Write-Host "Running GitHub CI parity checks..." -ForegroundColor Cyan

Assert-Command -Name "flutter"
Assert-Command -Name "dart"

$scriptRoot = $PSScriptRoot

Write-Host "[1/6] flutter pub get" -ForegroundColor Green
flutter pub get
Assert-LastExitCode -Step "flutter pub get"

Write-Host "[2/6] GitHub-exclusive guardrails" -ForegroundColor Green
& (Join-Path $scriptRoot "verify_github_exclusive.ps1")
Assert-LastExitCode -Step "GitHub-exclusive guardrails"

Write-Host "[3/6] dart format check" -ForegroundColor Green
dart format --output=none --set-exit-if-changed lib test
Assert-LastExitCode -Step "dart format check"

Write-Host "[4/6] flutter analyze" -ForegroundColor Green
flutter analyze
Assert-LastExitCode -Step "flutter analyze"

Write-Host "[5/6] flutter test" -ForegroundColor Green
flutter test
Assert-LastExitCode -Step "flutter test"

Write-Host "[6/6] flutter build web" -ForegroundColor Green
flutter build web --release --dart-define=APP_FLAVOR=production
Assert-LastExitCode -Step "flutter build web"

Write-Host "GitHub CI parity checks passed." -ForegroundColor Green
