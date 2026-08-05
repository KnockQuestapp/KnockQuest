param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum",
  [switch]$Force
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

    # Reject near-black loading frames with tiny logo traces.
    if ($darkRatio -gt 0.94 -and $brightRatio -lt 0.06) {
      return $false
    }

    return $true
  }
  finally {
    $bmp.Dispose()
  }
}

if ([Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
  throw "Clipboard image access requires STA. Run with: powershell.exe -STA -ExecutionPolicy Bypass -File .\\scripts\\capture_flutterflow_missing_manual.ps1"
}

Ensure-ClipboardTypes

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

$targets = @(
  [pscustomobject]@{
    RelativePath = "backend\\auth-providers.png"
    Panel = "Backend -> Authentication -> Providers"
    Tip = "Capture the providers list/toggles and enabled methods."
  },
  [pscustomobject]@{
    RelativePath = "backend\\users-fields.png"
    Panel = "Backend -> Firestore -> users collection fields"
    Tip = "Capture all field names and types in one shot."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\widget-tree.png"
    Panel = "UI Builder -> MainDashboard -> Widget Tree"
    Tip = "Capture left widget tree with hierarchy visible."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-add-lead.png"
    Panel = "UI Builder -> MainDashboard -> Action panel for Add Lead trigger"
    Tip = "Select the Add Lead trigger widget/button before snipping."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-open-map.png"
    Panel = "UI Builder -> MainDashboard -> Action panel for Open Map trigger"
    Tip = "Select the Open Map trigger widget/button before snipping."
  },
  [pscustomobject]@{
    RelativePath = "pages\\MainDashboard\\action-follow-ups.png"
    Panel = "UI Builder -> MainDashboard -> Action panel for Follow Ups trigger"
    Tip = "Select the Follow Ups trigger widget/button before snipping."
  },
  [pscustomobject]@{
    RelativePath = "pages\\AddLead\\action-save-lead.png"
    Panel = "UI Builder -> AddLead -> Action panel for Save Lead"
    Tip = "Select the Save Lead action widget/button before snipping."
  },
  [pscustomobject]@{
    RelativePath = "pages\\InteractiveMap\\action-draw-boundary.png"
    Panel = "UI Builder -> InteractiveMap -> Action panel for Draw Boundary"
    Tip = "Select the Draw Boundary trigger before snipping."
  }
)

Write-Host ""
Write-Host "FlutterFlow missing-panel capture"
Write-Host "Root: $targetRoot"
Write-Host ""
Write-Host "For each step:"
Write-Host "1) Open the panel in FlutterFlow"
Write-Host "2) Press Win+Shift+S and snip the panel"
Write-Host "3) Return here and press Enter to save clipboard image"
Write-Host ""

$captured = @()
$skipped = @()

for ($i = 0; $i -lt $targets.Count; $i++) {
  $target = $targets[$i]
  $outputPath = Join-Path $targetRoot $target.RelativePath
  $done = Is-CompletedFile -Path $outputPath

  if ($done -and -not $Force) {
    Write-Host "[$($i + 1)/$($targets.Count)] Already captured: $($target.RelativePath)"
    continue
  }

  while ($true) {
    Write-Host ""
    Write-Host "[$($i + 1)/$($targets.Count)] $($target.Panel)"
    Write-Host "Target: $($target.RelativePath)"
    Write-Host "Tip: $($target.Tip)"
    $response = Read-Host "Press Enter to save clipboard image, type 'skip' to skip, or 'quit' to stop"

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
      Write-Host "No image found in clipboard. Snip again and retry." -ForegroundColor Yellow
      continue
    }

    if (-not (Is-CompletedFile -Path $outputPath)) {
      Write-Host "Saved, but file looks too small. Retake this panel." -ForegroundColor Yellow
      continue
    }

    if (-not (Test-CaptureQuality -Path $outputPath)) {
      Write-Host "Saved image looks like a loading/blank frame. Retake this panel." -ForegroundColor Yellow
      continue
    }

    Write-Host "Saved: $($target.RelativePath)" -ForegroundColor Green
    $captured += $target.RelativePath
    break
  }
}

Write-Host ""
Write-Host "Capture complete"
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
Write-Host "Next: powershell.exe -ExecutionPolicy Bypass -File .\\scripts\\summarize_flutterflow_minimum_capture.ps1"
