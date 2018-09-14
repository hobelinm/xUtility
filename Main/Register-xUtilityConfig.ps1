<#
.SYNOPSIS
Used to register xUtility configuration

.DESCRIPTION
Uses ConfigHive to register module's default configuration into the system allowing for user configuration values to be
used

.NOTES
This function is not intended for user invocation

#>

function Register-xUtilityConfig {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  $hiveModule = Get-Module -Name 'ConfigHive' -ListAvailable
  if ($null -eq $hiveModule) {
    throw [xUtilityException]::New(
      'Register-xUtilityConfig',
      [xUtilityErrorCategory]::DependencyNotFound,
      "ConfigHive module needs to be installed on this system in order to use this method")
  }

  $hiveName = GetConfig('Module.Config.HiveName')
  $isRegistered = Get-RegisteredHives | Where-Object { $_ -eq $hiveName }
  if ($null -eq $isRegistered) {
    Print -Message 'About to register xUtility within ConfigHive module'
    $dataStoreInfo = @{
      'HiveName'   = $hiveName
      'StoreName'  = 'CliFileStore'
      'StoreLevel' = 'User'
    }

    $userDataStore = New-DataStore @dataStoreInfo
    Register-ConfigHive -HiveName $hiveName -UserStore $userDataStore
  }

  # Seed default values
  Initialize-DataStore -HiveName $hiveName -Level Origin -Data $Script:defaultConfig
}
