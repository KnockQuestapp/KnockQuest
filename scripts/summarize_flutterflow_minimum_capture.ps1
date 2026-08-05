param(
  [string]$Root = ".\\artifacts\\flutterflow_minimum",
  [switch]$ShowMissing
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$rootPath = Resolve-Path -LiteralPath "." | Select-Object -ExpandProperty Path
$targetRoot = Join-Path $rootPath $Root

if (-not (Test-Path $targetRoot)) {
  throw "Minimum capture root not found: $targetRoot"
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

Get-ChildItem -Path $targetRoot -Directory | Sort-Object Name | ForEach-Object {
  $dir = $_
  $files = Get-ChildItem -Path $dir.FullName -Recurse -File | Where-Object {
    $_.Name -ne 'notes.txt' -and $_.Name -ne 'capture_queue.txt'
  }
  $done = ($files | Where-Object { $_.Length -ge 100 -and (Test-CaptureQuality -Path $_.FullName) }).Count
  $total = $files.Count
  Write-Output ("{0}: {1}/{2}" -f $dir.Name, $done, $total)

  if ($ShowMissing) {
    $missing = $files | Where-Object { $_.Length -lt 100 -or (-not (Test-CaptureQuality -Path $_.FullName)) }
    foreach ($item in $missing) {
      $relative = $item.FullName.Replace($targetRoot + '\\', '')
      Write-Output ("- missing: {0}" -f $relative)
    }
  }
}
