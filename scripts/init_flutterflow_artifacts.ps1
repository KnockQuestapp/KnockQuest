param(
  [string]$Root = ".\\artifacts\\flutterflow"
)

$ErrorActionPreference = "Stop"

$pages = @(
  "LoginRegistration",
  "MainDashboard",
  "AddLead",
  "InteractiveMap",
  "LeadDetails",
  "VisitLoggerHistory",
  "FollowUpsReminders",
  "TerritoryManagement",
  "BusinessAnalytics",
  "CRMIntegrations",
  "SubscriptionThemes"
)

$components = @(
  "TextField",
  "OutcomeChip",
  "SourceRow",
  "PieChart",
  "PlanCard",
  "MapAction",
  "TabGroup",
  "VisitLogItem",
  "SwitchComponent",
  "ThemeSwatch"
)

$commonFiles = @(
  "page-preview.png",
  "widget-tree.png",
  "notes.txt"
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
  "FollowUpsReminders" = @(
    "action-calendar.png",
    "action-follow-up-card.png"
  )
  "TerritoryManagement" = @(
    "action-draw-new-boundary.png",
    "action-view-map.png",
    "action-search-filter.png"
  )
  "BusinessAnalytics" = @(
    "action-time-range.png",
    "data-bindings.png"
  )
  "CRMIntegrations" = @(
    "action-configure-salesforce.png",
    "action-configure-hubspot.png",
    "action-map-custom-fields.png"
  )
  "SubscriptionThemes" = @(
    "action-plan-selection.png",
    "action-theme-selection.png"
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

$storyboardFiles = @(
  "storyboard-overview-1.png",
  "storyboard-overview-2.png",
  "notes.txt"
)

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root

$folders = @(
  $targetRoot,
  (Join-Path $targetRoot "storyboard"),
  (Join-Path $targetRoot "backend"),
  (Join-Path $targetRoot "components")
)

foreach ($folder in $folders) {
  New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

foreach ($page in $pages) {
  $pageDir = Join-Path $targetRoot (Join-Path "pages" $page)
  New-Item -ItemType Directory -Path $pageDir -Force | Out-Null

  foreach ($file in $commonFiles) {
    $path = Join-Path $pageDir $file
    if (-not (Test-Path $path)) {
      if ($file -eq "notes.txt") {
        Set-Content -Path $path -Value "Buttons and rules for $page`n- describe what each major button does`n- note required fields`n- note page load queries" -Encoding UTF8
      } else {
        Set-Content -Path $path -Value "" -Encoding UTF8
      }
    }
  }

  if ($pageSpecific.ContainsKey($page)) {
    foreach ($file in $pageSpecific[$page]) {
      $path = Join-Path $pageDir $file
      if (-not (Test-Path $path)) {
        Set-Content -Path $path -Value "" -Encoding UTF8
      }
    }
  }
}

foreach ($component in $components) {
  $componentDir = Join-Path $targetRoot (Join-Path "components" $component)
  New-Item -ItemType Directory -Path $componentDir -Force | Out-Null
  foreach ($file in @("preview.png", "widget-tree.png", "notes.txt")) {
    $path = Join-Path $componentDir $file
    if (-not (Test-Path $path)) {
      if ($file -eq "notes.txt") {
        Set-Content -Path $path -Value "Component notes for $component" -Encoding UTF8
      } else {
        Set-Content -Path $path -Value "" -Encoding UTF8
      }
    }
  }
}

foreach ($file in $backendFiles) {
  $path = Join-Path (Join-Path $targetRoot "backend") $file
  if (-not (Test-Path $path)) {
    if ($file -eq "notes.txt") {
      Set-Content -Path $path -Value "Backend notes`n- auth provider behavior`n- collection relationships`n- role rules`n- API/webhook details" -Encoding UTF8
    } else {
      Set-Content -Path $path -Value "" -Encoding UTF8
    }
  }
}

foreach ($file in $storyboardFiles) {
  $path = Join-Path (Join-Path $targetRoot "storyboard") $file
  if (-not (Test-Path $path)) {
    if ($file -eq "notes.txt") {
      Set-Content -Path $path -Value "Storyboard notes`n- page to page navigation`n- hidden modal flows`n- conditional routes" -Encoding UTF8
    } else {
      Set-Content -Path $path -Value "" -Encoding UTF8
    }
  }
}

$manifest = [ordered]@{
  createdAt = (Get-Date).ToString("s")
  root = $targetRoot
  pages = $pages
  components = $components
  backend = $backendFiles
}

$manifestPath = Join-Path $targetRoot "capture_manifest.json"
$manifest | ConvertTo-Json -Depth 6 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Output "Initialized FlutterFlow artifact scaffold at $targetRoot"
