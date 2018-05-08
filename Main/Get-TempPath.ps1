<#
.SYNOPSIS
Returns the path of the temporary folder

.DESCRIPTION
Returns the path of the temporary folder. This path is different between Windows, Mac OS, and Linux, this function
abstract those differences

#>

function Get-TempPath {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  Write-Output (GetTempPath -BasePath)
}
