<#
.SYNOPSIS
Test for the latest version of PowerShell Core and compare it against the local version

.DESCRIPTION
Checks the latest version of PowerShell Core and compare it against the local version

#>

function Test-PowerShellVersion {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  # Get the version of PowerShell Core
  $versionSource = GetConfig('Module.PowerShell.Core.LatestVersionSource')
  $headers = GetConfig('Module.PowerShell.Core.RequestHeaders')
  $latestVersion = ''
  try {
    $latestVersionObject = Invoke-RestMethod -Method Get -Uri $versionSource -Headers $headers
    $latestVersion = [string] $latestVersionObject.tag_name
    $latestVersion = $latestVersion.Replace('v', '')
  }
  catch {
    $e = $_
    # TODO: Write Telemetry
    return
  }
  
  $versions = [PSCustomObject]@{
    'Latest' = [System.Version] $latestVersion
    'Current' = $PSVersionTable.PSVersion
  }
  
  Write-Output $versions
  # TODO: Write Telemetry
}
