param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum"
)

$ErrorActionPreference = "Stop"

$targets = [ordered]@{
  "pages\\LoginRegistration" = @(
    "widget-tree.png",
    "action-login.png",
    "action-google-signin.png"
  )
  "pages\\MainDashboard" = @(
    "widget-tree.png",
    "action-add-lead.png",
    "action-open-map.png",
    "action-follow-ups.png"
  )
  "pages\\AddLead" = @(
    "widget-tree.png",
    "action-save-lead.png"
  )
  "pages\\InteractiveMap" = @(
    "widget-tree.png",
    "action-draw-boundary.png"
  )
  "backend" = @(
    "auth-providers.png",
    "collections-overview.png",
    "users-fields.png",
    "leads-fields.png"
  )
}

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

foreach ($entry in $targets.GetEnumerator()) {
  $dir = Join-Path $targetRoot $entry.Key
  New-Item -ItemType Directory -Path $dir -Force | Out-Null

  foreach ($file in $entry.Value) {
    $path = Join-Path $dir $file
    if (-not (Test-Path $path)) {
      Set-Content -Path $path -Value "" -Encoding UTF8
    }
  }

  $notesPath = Join-Path $dir "notes.txt"
  if (-not (Test-Path $notesPath)) {
    Set-Content -Path $notesPath -Value "Minimum capture notes for $($entry.Key)" -Encoding UTF8
  }
}

$queue = @(
  'pages\\LoginRegistration\\widget-tree.png',
  'pages\\LoginRegistration\\action-login.png',
  'pages\\LoginRegistration\\action-google-signin.png',
  'backend\\auth-providers.png',
  'backend\\collections-overview.png',
  'backend\\users-fields.png',
  'backend\\leads-fields.png',
  'pages\\MainDashboard\\widget-tree.png',
  'pages\\MainDashboard\\action-add-lead.png',
  'pages\\MainDashboard\\action-open-map.png',
  'pages\\MainDashboard\\action-follow-ups.png',
  'pages\\AddLead\\widget-tree.png',
  'pages\\AddLead\\action-save-lead.png',
  'pages\\InteractiveMap\\widget-tree.png',
  'pages\\InteractiveMap\\action-draw-boundary.png'
)

$queuePath = Join-Path $targetRoot "capture_queue.txt"
@(
  'FlutterFlow Minimum Capture Queue',
  "Generated: $(Get-Date -Format s)",
  ''
) + ($queue | ForEach-Object { "- $_" }) | Set-Content -Path $queuePath -Encoding UTF8

Write-Output "Initialized FlutterFlow minimum capture scaffold at $targetRoot"
