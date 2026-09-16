param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum"
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root

if (-not (Test-Path -LiteralPath $targetRoot)) {
  throw "Capture root not found: $targetRoot"
}

$required = @(
  "backend\\auth-providers.png",
  "backend\\users-fields.png",
  "pages\\MainDashboard\\widget-tree.png",
  "pages\\MainDashboard\\action-add-lead.png",
  "pages\\MainDashboard\\action-open-map.png",
  "pages\\MainDashboard\\action-follow-ups.png",
  "pages\\AddLead\\action-save-lead.png",
  "pages\\InteractiveMap\\action-draw-boundary.png"
)

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

$done = @()
$missing = @()

foreach ($item in $required) {
  $path = Join-Path $targetRoot $item
  if ((Test-Path -LiteralPath $path) -and ((Get-Item -LiteralPath $path).Length -ge 100) -and (Test-CaptureQuality -Path $path)) {
    $done += $item
  }
  else {
    $missing += $item
  }
}

Write-Output ("exact-required: {0}/{1}" -f $done.Count, $required.Count)

if ($done.Count -gt 0) {
  Write-Output ""
  Write-Output "completed:"
  $done | ForEach-Object { Write-Output ("- {0}" -f $_) }
}

if ($missing.Count -gt 0) {
  Write-Output ""
  Write-Output "missing:"
  $missing | ForEach-Object { Write-Output ("- {0}" -f $_) }
}
