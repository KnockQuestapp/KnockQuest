param(
  [ValidateSet('check', 'web', 'windows', 'android', 'doctor')]
  [string]$Task = 'check'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$toolchainRoot = Join-Path $projectRoot '.toolchains'
$flutterBin = Join-Path $toolchainRoot 'flutter\bin'
$flutter = Join-Path $flutterBin 'flutter.bat'

if (-not (Test-Path -LiteralPath $flutter)) {
  throw "Flutter SDK is missing at $flutter"
}

$env:PATH = "$flutterBin;$env:PATH"
$env:PUB_CACHE = Join-Path $toolchainRoot 'pub-cache'
$env:GRADLE_USER_HOME = Join-Path $toolchainRoot 'gradle'
$env:JAVA_HOME = Join-Path $toolchainRoot 'jdk\jdk-17.0.20.1+1'
$env:ANDROID_HOME = Join-Path $toolchainRoot 'android-sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:ANDROID_USER_HOME = Join-Path $toolchainRoot 'android-user'
New-Item -ItemType Directory -Force -Path $env:PUB_CACHE | Out-Null
New-Item -ItemType Directory -Force -Path $env:GRADLE_USER_HOME | Out-Null
New-Item -ItemType Directory -Force -Path $env:ANDROID_USER_HOME | Out-Null
if (Test-Path (Join-Path $env:JAVA_HOME 'bin\java.exe')) {
  $env:PATH = "$(Join-Path $env:JAVA_HOME 'bin');$env:PATH"
}
Set-Location -LiteralPath $projectRoot

switch ($Task) {
  'check' {
    & $flutter config --no-enable-windows-desktop | Out-Null
    & (Join-Path $PSScriptRoot 'run_github_ci_parity.ps1')
  }
  'web' {
    & $flutter config --no-enable-windows-desktop | Out-Null
    & $flutter run -d chrome --dart-define=APP_FLAVOR=staging
  }
  'windows' {
    & $flutter config --enable-windows-desktop | Out-Null
    $dataDir = Join-Path $toolchainRoot 'local-data'
    New-Item -ItemType Directory -Force -Path $dataDir | Out-Null
    & $flutter run -d windows --dart-define=APP_FLAVOR=staging "--dart-define=LOCAL_DATA_DIR=$dataDir"
  }
  'android' {
    if (-not (Test-Path (Join-Path $env:ANDROID_HOME 'platforms\android-36'))) {
      throw "Android SDK packages are missing at $env:ANDROID_HOME"
    }
    & $flutter config --android-sdk $env:ANDROID_HOME | Out-Null
    & $flutter config --jdk-dir $env:JAVA_HOME | Out-Null
    & $flutter build apk --debug --flavor staging --dart-define=APP_FLAVOR=staging
  }
  'doctor' { & $flutter doctor -v }
}

if ($LASTEXITCODE -ne 0) {
  exit $LASTEXITCODE
}
