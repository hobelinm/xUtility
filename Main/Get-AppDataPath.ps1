<#
.SYNOPSIS
Gets the path of the local app data folder

.DESCRIPTION
Deals with inconsistencies between supported operating systems and gets the App data folder or equivalent

#>

function Get-AppDataPath {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  Write-Output (GetAppDataPath -BasePath)
}
