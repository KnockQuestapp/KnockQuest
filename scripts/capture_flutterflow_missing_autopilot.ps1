param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum",
  [string]$ProjectUrl = "https://app.flutterflow.io/project/knock-quest-ceh253",
  [int]$OpenDelaySeconds = 3,
  [switch]$Force,
  [switch]$NoOpen
)

$ErrorActionPreference = "Stop"

function Ensure-ClipboardTypes {
  Add-Type -AssemblyName System.Windows.Forms
  Add-Type -AssemblyName System.Drawing
}

function Save-ClipboardImage {
  param(
    [Parameter(Mandatory = $true)][string]$OutputPath
  )

  $image = [System.Windows.Forms.Clipboard]::GetImage()
  if ($null -eq $image) {
    return $false
  }

  $parent = Split-Path -Parent $OutputPath
  if (-not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  $image.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $image.Dispose()
  return $true
}

function Is-CompletedFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $item = Get-Item -LiteralPath $Path
  return $item.Length -ge 100
}

function Test-CaptureQuality {
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  $bmp = New-Object System.Drawing.Bitmap($Path)
  try {
    $step = 6
    $samples = 0
    $dark = 0
    $bright = 0

    for ($y = 0; $y -lt $bmp.Height; $y += $step) {
      for ($x = 0; $x -lt $bmp.Width; $x += $step) {
        $c = $bmp.GetPixel($x, $y)
        $samples++
        if ($c.R -lt 30 -and $c.G -lt 30 -and $c.B -lt 30) {
          $dark++
        }
        if ($c.R -gt 80 -or $c.G -gt 80 -or $c.B -gt 80) {
          $bright++
        }
      }
    }

    if ($samples -eq 0) {
      return $false
    }

    $darkRatio = [double]$dark / [double]$samples
    $brightRatio = [double]$bright / [double]$samples

    if ($darkRatio -gt 0.94 -and $brightRatio -lt 0.06) {
      return $false
    }

    return $true
  }
  finally {
    $bmp.Dispose()
  }
}

function Open-Panel {
  param(
    [Parameter(Mandatory = $true)][string]$Url,
    [Parameter(Mandatory = $true)][int]$DelaySeconds
  )

  $launched = $false
  $errors = @()

  $browserCandidates = @()
  if ($env:BROWSER) {
    $browserCandidates += $env:BROWSER
  }
  $browserCandidates += @("msedge.exe", "chrome.exe", "firefox.exe")

  foreach ($candidate in $browserCandidates) {
    if ([string]::IsNullOrWhiteSpace($candidate)) {
      continue
    }

    try {
      $command = Get-Command $candidate -ErrorAction Stop
      Start-Process -FilePath $command.Source -ArgumentList @($Url) | Out-Null
      $launched = $true
      break
    }
    catch {
      $errors += "${candidate}: $($_.Exception.Message)"
    }
  }

  if (-not $launched) {
    try {
      Start-Process -FilePath "explorer.exe" -ArgumentList @($Url) | Out-Null
      $launched = $true
    }
    catch {
      $errors += "explorer.exe: $($_.Exception.Message)"
    }
  }

  if (-not $launched) {
    $details = ($errors | Select-Object -Unique) -join "; "
    throw "Failed to open URL '$Url'. Launch attempts: $details"
  }

  if ($DelaySeconds -gt 0) {
    Start-Sleep -Seconds $DelaySeconds
  }
}

if ([Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
  throw "Clipboard image access requires STA. Run with: powershell.exe -STA -ExecutionPolicy Bypass -File .\\scripts\\capture_flutterflow_missing_autopilot.ps1"
}

Ensure-ClipboardTypes

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

$targets = @(
  [pscustomobject]@{
    RelativePath = "backend\\auth-providers.png"
    Url = "${ProjectUrl}?tab=authentication"
    Panel = "Backend -> Authentication -> Providers"
    Tip = "Ensure enabled providers and auth methods are visible."
  },
  [pscustomobject]@{
    RelativePath = "backend\\users-fields.png"
    Url = "${ProjectUrl}?tab=database"
    Panel = "Backend -> Firestore -> users fields"
    Tip = "Open users collection and show all field names + types."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\widget-tree.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=MainDashboard"
    Panel = "MainDashboard -> Widget Tree"
    Tip = "Keep left widget tree expanded."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-add-lead.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=MainDashboard"
    Panel = "MainDashboard -> Add Lead action"
    Tip = "Select Add Lead trigger and open the Actions panel before snip."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-open-map.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=MainDashboard"
    Panel = "MainDashboard -> Open Map action"
    Tip = "Select Open Map trigger and open the Actions panel before snip."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-follow-ups.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=MainDashboard"
    Panel = "MainDashboard -> Follow Ups action"
    Tip = "Select Follow Ups trigger and open the Actions panel before snip."
  },
  [pscustomobject]@{
    RelativePath = "pages\\AddLead\\action-save-lead.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=AddLead"
    Panel = "AddLead -> Save Lead action"
    Tip = "Select Save Lead and open its Actions panel before snip."
  },
  [pscustomobject]@{
    RelativePath = "pages\\InteractiveMap\\action-draw-boundary.png"
    Url = "${ProjectUrl}?tab=uiBuilder&page=InteractiveMap"
    Panel = "InteractiveMap -> Draw Boundary action"
    Tip = "Select Draw Boundary trigger and open the Actions panel before snip."
  }
)

Write-Host ""
Write-Host "FlutterFlow autopilot capture"
Write-Host "Root: $targetRoot"
Write-Host "Open delay: $OpenDelaySeconds sec"
Write-Host ""
Write-Host "Workflow:"
Write-Host "1) Script opens target panel URL"
Write-Host "2) You finalize panel state in browser"
Write-Host "3) Press Win+Shift+S"
Write-Host "4) Return here and press Enter to save"
Write-Host ""

$captured = @()
$skipped = @()

for ($i = 0; $i -lt $targets.Count; $i++) {
  $target = $targets[$i]
  $outputPath = Join-Path $targetRoot $target.RelativePath

  if ((Is-CompletedFile -Path $outputPath) -and (Test-CaptureQuality -Path $outputPath) -and -not $Force) {
    Write-Host "[$($i + 1)/$($targets.Count)] Already captured: $($target.RelativePath)"
    continue
  }

  if (-not $NoOpen) {
    Open-Panel -Url $target.Url -DelaySeconds $OpenDelaySeconds
  }

  while ($true) {
    Write-Host ""
    Write-Host "[$($i + 1)/$($targets.Count)] $($target.Panel)"
    Write-Host "Target: $($target.RelativePath)"
    Write-Host "URL: $($target.Url)"
    Write-Host "Tip: $($target.Tip)"
    $response = Read-Host "Enter=save, 'open'=reopen URL, 'skip'=skip, 'quit'=stop"

    if ($response -eq "open") {
      if ($NoOpen) {
        Write-Host "NoOpen is enabled. Re-run without -NoOpen to auto-open URLs." -ForegroundColor Yellow
      }
      else {
        Open-Panel -Url $target.Url -DelaySeconds $OpenDelaySeconds
      }
      continue
    }

    if ($response -eq "skip") {
      $skipped += $target.RelativePath
      break
    }

    if ($response -eq "quit") {
      $remaining = $targets[($i)..($targets.Count - 1)] | ForEach-Object { $_.RelativePath }
      $skipped += $remaining
      $i = $targets.Count
      break
    }

    $saved = Save-ClipboardImage -OutputPath $outputPath
    if (-not $saved) {
      Write-Host "No image in clipboard. Snip panel and try again." -ForegroundColor Yellow
      continue
    }

    if (-not (Is-CompletedFile -Path $outputPath)) {
      Write-Host "Saved file is too small; retake this panel." -ForegroundColor Yellow
      continue
    }

    if (-not (Test-CaptureQuality -Path $outputPath)) {
      Write-Host "Saved image looks like a loading/blank frame; retake this panel." -ForegroundColor Yellow
      continue
    }

    Write-Host "Saved: $($target.RelativePath)" -ForegroundColor Green
    $captured += $target.RelativePath
    break
  }
}

Write-Host ""
Write-Host "Run complete"
Write-Host "Captured this run: $($captured.Count)"
Write-Host "Skipped/remaining: $($skipped.Count)"

if ($captured.Count -gt 0) {
  Write-Host ""
  Write-Host "Captured:"
  $captured | ForEach-Object { Write-Host "- $_" }
}

if ($skipped.Count -gt 0) {
  Write-Host ""
  Write-Host "Skipped/remaining:"
  $skipped | ForEach-Object { Write-Host "- $_" }
}

Write-Host ""
Write-Host "Next: powershell.exe -ExecutionPolicy Bypass -File .\\scripts\\summarize_flutterflow_missing_exact.ps1"
