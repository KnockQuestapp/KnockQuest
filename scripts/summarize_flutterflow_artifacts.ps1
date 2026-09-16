param(
  [string]$Root = ".\\artifacts\\flutterflow",
  [switch]$ShowMissing
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root

if (-not (Test-Path $targetRoot)) {
  throw "Artifact root not found: $targetRoot"
}

function Test-CaptureQuality {
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path)) {
    return $false
  }

  if (([System.IO.Path]::GetExtension($Path)).ToLowerInvariant() -ne ".png") {
    return $true
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

$groups = Get-ChildItem -Path (Join-Path $targetRoot "pages") -Directory | Sort-Object Name

foreach ($group in $groups) {
  $files = Get-ChildItem -Path $group.FullName -File | Where-Object { $_.Name -ne "notes.txt" }
  $done = ($files | Where-Object { $_.Length -ge 100 -and (Test-CaptureQuality -Path $_.FullName) }).Count
  $total = $files.Count
  Write-Output ("{0}: {1}/{2}" -f $group.Name, $done, $total)

  if ($ShowMissing) {
    $missing = $files | Where-Object { $_.Length -lt 100 -or (-not (Test-CaptureQuality -Path $_.FullName)) }
    foreach ($item in $missing) {
      $relative = $item.FullName.Replace($targetRoot + '\\', '')
      Write-Output ("- missing: {0}" -f $relative)
    }
  }
}

$backendDir = Join-Path $targetRoot "backend"
if (Test-Path $backendDir) {
  $files = Get-ChildItem -Path $backendDir -File | Where-Object { $_.Name -ne "notes.txt" }
  $done = ($files | Where-Object { $_.Length -ge 100 -and (Test-CaptureQuality -Path $_.FullName) }).Count
  $total = $files.Count
  Write-Output ("backend: {0}/{1}" -f $done, $total)

  if ($ShowMissing) {
    $missing = $files | Where-Object { $_.Length -lt 100 -or (-not (Test-CaptureQuality -Path $_.FullName)) }
    foreach ($item in $missing) {
      $relative = $item.FullName.Replace($targetRoot + '\\', '')
      Write-Output ("- missing: {0}" -f $relative)
    }
  }
}
