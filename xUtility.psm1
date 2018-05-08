$ErrorActionPreference = 'Stop'

# Global variables
$Script:ModuleHome = $PSScriptRoot
<# Expiring Cache Initialization #>
$script:expiringCacheObjects = @{}

$mainFolder = Join-Path -Path $Script:ModuleHome -ChildPath "Main"

# Load Utilities and configuration first
$preloadScripts = @(
  'util.ps1',
  'config.ps1'
)

$preloadScripts | ForEach-Object {
  $preloadScript = Join-Path -Path $mainFolder -ChildPath $_
}

if (-not (Test-Path (GetConfig('Module.WorkPath')))) {
  New-Item -ItemType Directory -Path (GetConfig('Module.WorkPath')) | Write-Verbose
}

# Load cmdlets
if ((GetConfig('Module.IsWindows')) -eq $false) {
  $preloadScripts += GetConfig('Module.WindowsOnlyScripts')
}

# When integrated with PsConfigHive module allows to skip custom prompt if Config module is already loaded
if ((GetConfig('Module.NoCustomPrompt')) -eq $true) {
  $preloadScripts += 'Set-Prompt.ps1'
}

# Load all functions
Get-ChildItem -Filter '*.ps1' -Recurse -Path $mainFolder | Where-Object {
  $preloadScripts.Contains($_.Name) -eq $false
} | ForEach-Object {
  . ($_.FullName)
}

# Check the latest version
$traceVersionFile  = GetConfig('Module.VersionTraceFile')
$checkVersion = $false
if (-not (Test-Path $traceVersionFile)) {
  $checkVersion = $true
}
else {
  $checkSpan = [TimeSpan] (GetConfig('Module.UpdateCheckSpan'))
  $versionCheck = [DateTime] (Import-Clixml -Path $traceVersionFile)
  if ($versionCheck.Add($checkSpan) -le (Get-Date)) {
    $checkVersion = $true
  }
}

$warnVersion = $false
$latestVersion = $null
if ($checkVersion) {
  $thisVersion = [Version] (GetConfig('Module.Version'))
  $versionUrl = GetConfig('Module.PackageVersionUrl')
  $response = Invoke-WebRequest -Uri $versionUrl
  $package = $response.Content | ConvertFrom-Json
  $latestVersion = [Version] $package.version
  if ($latestVersion -gt $thisVersion) {
    $warnVersion = $true
  }
  else {
    (Get-Date) | Export-Clixml -Path $traceVersionFile
  }
}


# Print load message
Print -Message 'xUtility v' -NoNewLine
$mVersion = (GetConfig('Module.Version')).ToString().Split('.')
$idx = 0
$mVersion | ForEach-Object {
  $digit = $_
  Write-Host $digit -NoNewline -ForegroundColor Green
  if ($idx -lt ($mVersion.Count - 1)) {
    Write-Host '.' -NoNewline
  }

  $idx++
}

if ($warnVersion) {
  Write-Host ''
  $m = "Update to v{0} to get access to the latest features" -f $latestVersion
  Print -Message $m -Accent 'Yellow'
}
