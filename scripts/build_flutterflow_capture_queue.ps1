param(
  [string]$Root = ".\\artifacts\\flutterflow",
  [string]$OutFile = ".\\artifacts\\flutterflow\\capture_queue.txt"
)

$ErrorActionPreference = "Stop"

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root
$outPath = Join-Path $rootPath $OutFile

if (-not (Test-Path $targetRoot)) {
  throw "Artifact root not found: $targetRoot"
}

$priorityPatterns = @(
  "pages\\LoginRegistration\\widget-tree.png",
  "pages\\LoginRegistration\\action-login.png",
  "pages\\LoginRegistration\\action-google-signin.png",
  "pages\\MainDashboard\\widget-tree.png",
  "pages\\MainDashboard\\page-load-actions.png",
  "pages\\MainDashboard\\action-add-lead.png",
  "pages\\AddLead\\widget-tree.png",
  "pages\\AddLead\\action-save-lead.png",
  "pages\\InteractiveMap\\widget-tree.png",
  "pages\\InteractiveMap\\action-draw-boundary.png",
  "backend\\auth-providers.png",
  "backend\\collections-overview.png",
  "backend\\users-fields.png",
  "backend\\leads-fields.png"
)

$files = Get-ChildItem -Path $targetRoot -Recurse -File | Where-Object {
  $_.Name -ne "notes.txt" -and $_.Name -ne ".gitkeep" -and $_.Name -ne "capture_manifest.json" -and $_.Length -lt 100
} | ForEach-Object {
  $_.FullName.Replace($targetRoot + '\\', '')
}

$priority = New-Object System.Collections.Generic.List[string]
$remaining = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
  if ($priorityPatterns -contains $file) {
    $priority.Add($file)
  } else {
    $remaining.Add($file)
  }
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("FlutterFlow Capture Queue") | Out-Null
$lines.Add("Generated: $(Get-Date -Format s)") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("Priority First") | Out-Null
foreach ($item in $priority) {
  $lines.Add("- $item") | Out-Null
}
$lines.Add("") | Out-Null
$lines.Add("Then Remaining") | Out-Null
foreach ($item in ($remaining | Sort-Object)) {
  $lines.Add("- $item") | Out-Null
}

$dir = Split-Path -Parent $outPath
New-Item -ItemType Directory -Path $dir -Force | Out-Null
$lines | Set-Content -Path $outPath -Encoding UTF8

Write-Output "Wrote capture queue to $outPath"
