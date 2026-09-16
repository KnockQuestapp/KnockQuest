param(
  [string]$Root = ".\\artifacts\\flutterflow"
)

$ErrorActionPreference = "Stop"

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root
$manifestPath = Join-Path $targetRoot "capture_manifest.json"

if (-not (Test-Path $manifestPath)) {
  throw "Manifest not found. Run ./scripts/init_flutterflow_artifacts.ps1 first."
}

$manifest = Get-Content -Path $manifestPath -Raw | ConvertFrom-Json
$missing = New-Object System.Collections.Generic.List[string]

Get-ChildItem -Path $targetRoot -Recurse -File | ForEach-Object {
  $isPlaceholderText = $_.Extension -eq ".txt" -and $_.Name -ne "notes.txt" -and $_.Length -eq 0
  $isPlaceholderImage = $_.Extension -eq ".png" -and $_.Length -lt 100
  if (($isPlaceholderText -or $isPlaceholderImage) -and $_.Name -ne ".gitkeep") {
    $missing.Add($_.FullName.Replace($targetRoot + '\\', ''))
  }
}

Write-Output "Artifact root: $targetRoot"
Write-Output "Missing screenshot placeholders: $($missing.Count)"

if ($missing.Count -gt 0) {
  $missing | Sort-Object | ForEach-Object { Write-Output $_ }
} else {
  Write-Output "All screenshot placeholders are populated."
}
