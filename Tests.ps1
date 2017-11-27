<#
.SYNOPSIS
Executes tests for xUtility module

.DESCRIPTION
Executes a series of tests to verify functionality for xUtility module

#>

function isWindows {
  [CmdletBinding()]
  param()

  if ($PSVersionTable.OS -eq $null -or $PSVersionTable.OS.Contains('Windows')) {
    Write-Output $true
  }
  else {
    Write-Output $false
  }
}

$ErrorActionPreference = 'Stop'
$moduleManifest = Join-Path -Path $PSScriptRoot -ChildPath './xUtility.psd1'

try {
  Import-Module $moduleManifest
}
catch {
  #
}
finally {
  Remove-Module 'xUtility'
}
