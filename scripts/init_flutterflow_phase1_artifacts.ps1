param(
  [string]$Root = ".\\artifacts\\flutterflow_phase1"
)

$ErrorActionPreference = "Stop"

$pages = @(
  "LoginRegistration",
  "MainDashboard",
  "AddLead",
  "InteractiveMap",
  "LeadDetails",
  "VisitLoggerHistory",
  "TerritoryManagement"
)

$pageSpecific = @{
  "LoginRegistration" = @(
    "action-login.png",
    "action-google-signin.png",
    "action-register.png",
    "action-forgot-password.png"
  )
  "MainDashboard" = @(
    "action-add-lead.png",
    "action-open-map.png",
    "action-follow-ups.png",
    "action-export.png",
    "page-load-actions.png"
  )
  "AddLead" = @(
    "action-save-lead.png",
    "validation-rules.png",
    "field-bindings.png"
  )
  "InteractiveMap" = @(
    "action-search.png",
    "action-draw-boundary.png",
    "action-range-filters.png",
    "map-settings.png"
  )
  "LeadDetails" = @(
    "action-edit.png",
    "action-log-visit.png",
    "action-follow-up.png"
  )
  "VisitLoggerHistory" = @(
    "action-log-visit.png",
    "action-add-follow-up.png",
    "action-change-status.png"
  )
  "TerritoryManagement" = @(
    "action-draw-new-boundary.png",
    "action-view-map.png",
    "action-search-filter.png"
  )
}

$backendFiles = @(
  "auth-providers.png",
  "collections-overview.png",
  "users-fields.png",
  "leads-fields.png",
  "territories-fields.png",
  "followups-fields.png",
  "app-state.png",
  "api-calls.png",
  "custom-functions.png",
  "custom-actions.png",
  "notes.txt"
)

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root

New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetRoot "backend") -Force | Out-Null
New-Item -ItemType Directory -Path (Join-Path $targetRoot "pages") -Force | Out-Null

foreach ($page in $pages) {
  $pageDir = Join-Path $targetRoot (Join-Path "pages" $page)
  New-Item -ItemType Directory -Path $pageDir -Force | Out-Null

  foreach ($file in @("page-preview.png", "widget-tree.png", "notes.txt")) {
    $path = Join-Path $pageDir $file
    if (-not (Test-Path $path)) {
      if ($file -eq "notes.txt") {
        Set-Content -Path $path -Value "Critical notes for $page`n- describe primary user goal`n- list save/navigation behavior`n- list data queries and writes" -Encoding UTF8
      } else {
        Set-Content -Path $path -Value "" -Encoding UTF8
      }
    }
  }

  foreach ($file in $pageSpecific[$page]) {
    $path = Join-Path $pageDir $file
    if (-not (Test-Path $path)) {
      Set-Content -Path $path -Value "" -Encoding UTF8
    }
  }
}

foreach ($file in $backendFiles) {
  $path = Join-Path (Join-Path $targetRoot "backend") $file
  if (-not (Test-Path $path)) {
    if ($file -eq "notes.txt") {
      Set-Content -Path $path -Value "Critical backend notes`n- auth flow`n- lead status rules`n- territory ownership rules`n- visit logging writes" -Encoding UTF8
    } else {
      Set-Content -Path $path -Value "" -Encoding UTF8
    }
  }
}

$manifest = [ordered]@{
  createdAt = (Get-Date).ToString("s")
  root = $targetRoot
  phase = "phase1"
  pages = $pages
  backend = $backendFiles
}

$manifestPath = Join-Path $targetRoot "capture_manifest.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Output "Initialized FlutterFlow phase 1 artifact scaffold at $targetRoot"
