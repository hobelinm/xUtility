# Module Error Categories
enum xUtilityErrorCategory {
  CacheKeyNotFound
  DependencyNotFound
  DuplicateMatchingCriteria
  InconsistentMatchingTypes
  InsufficientPermission
  InvalidCacheKey
  InvalidImplementation
  InvalidParameter
  InvalidRetryLogicEvaluation
  MaxRetryLimitReached
}

enum ErrorRecordComparisonType {
  NoComparison
  TypeCompare
  ActivityCompare
  CategoryCompare
  IdCompare
  AnyCompare
}

# Custom error class
class xUtilityException : System.Exception {
  xUtilityException(
    [string] $methodName,
    [xUtilityErrorCategory] $category,
    [string] $message
  ) : base(("[{0}:{1}] {2}" -f $methodName, $category, $message)) {
    # Error message is handled by System.Exception
    Get-PSCallStack
    # TODO: Add telemetry here
  }
}

# Utils to determine the OS
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

function isLinux {
  [CmdletBinding()]
  param()

  if ($PSVersionTable -eq $null) {
    Write-Output $false
    return
  }

  if ($PSVersionTable.OS -match 'Linux') {
    Write-Output $true
    return
  }

  Write-Output $false
}

# Gets temp path according to the host
function GetTempPath {
  [CmdletBinding()]
  param(
    [Parameter()]
    [switch] $BasePath = $false
  )

  $location = ''
  if (isWindows) {
    $location = $env:TEMP
  }
  else {
    $location = $env:TMPDIR
    if ($location -eq $null -or -not (Test-Path $location)) {
      $location = '/tmp'
    }
  }

  if ($BasePath) {
    Write-Output $location
  }
  else {
    $location = Join-Path -Path $location -ChildPath 'xUtility'
    if (-not (Test-Path $location)) {
      New-Item -ItemType Directory -Path $location | Write-Verbose
    }
  
    Write-Output $location
  }
}

# Returns the app data directory for each OS
function GetAppDataPath {
  [CmdletBinding()]
  param(
    [Parameter()]
    [switch] $BasePath = $false
  )

  $location = ''
  if (isWindows) {
    $location = $env:LOCALAPPDATA
  }
  else {
    $location = '~/Library/Preferences/'
    if ($location -eq $null -or -not (Test-Path $location)) {
      $location = '~/.local/share/'
    }
  }

  if (-not $BasePath) {
    $location = Join-Path -Path $location -ChildPath 'xUtility'
    if (-not (Test-Path $location)) {
      New-Item -ItemType Directory -Path $location | Write-Verbose
    }
  }

  Write-Output $location
}

# Pretty print
function Print {
  [CmdletBinding()]
  param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string] $Header = [string]::Empty,

    [Parameter(Mandatory)]
    [string] $Message,

    [Parameter()]
    [System.ConsoleColor] $Accent = (GetConfig('Module.AccentColor')),

    [Parameter()]
    [switch] $NoNewLine = $false
  )

  Write-Host '[' -NoNewline
  $caller = '<ScriptBlock>'
  if ($Header -ne [string]::Empty) {
    Write-Host $Header -ForegroundColor $Accent -NoNewline
  }
  else {
    Write-Host 'xUtility' -ForegroundColor $Accent -NoNewline
    $caller = (Get-PSCallStack)[1].FunctionName
    
    if ($caller -ne '<ScriptBlock>') {
      Write-Host '.' -NoNewline
      Write-Host $caller -ForegroundColor $Accent -NoNewline
    }
  }
  
  if ($NoNewLine) {
    Write-Host "] $Message" -NoNewline
  }
  else {
    Write-Host "] $Message"
  }
}

function GetConfig {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string] $Key
  )

  $ErrorActionPreference = 'Stop'
  # Check for ConfigHive enabled
  $hiveName = $Script:defaultConfig['Module.Config.HiveName']
  if ($Script:IsConfigHiveOn -eq $false) {
    $hiveModule = Get-Module -Name 'ConfigHive'
    if ($hiveModule -ne $null) {
      $registeredHive = Get-RegisteredHives | Where-Object { $_ -eq $hiveName }
      if ($registeredHive -ne $null) {
        $Script:IsConfigHiveOn = $true
      }
    }
  }

  if ($Script:IsConfigHiveOn -eq $false) {
    Write-Output $Script:defaultConfig[$Key]
  }
  else {
    $val = Get-ConfigValue -Key $Key -HiveName $hiveName
    Write-Output $val
  }
}

function SetConfig {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $Key,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $Value
  )

  $ErrorActionPreference = 'Stop'
  $hiveName = $Script:defaultConfig['Module.Config.HiveName']
  if ($Script:IsConfigHiveOn -eq $false) {
    $hiveModule = Get-Module -Name 'ConfigHive'
    if ($hiveModule -ne $null) {
      $registeredHive = Get-RegisteredHives | Where-Object { $_ -eq $hiveName }
      if ($registeredHive -ne $null) {
        $Script:IsConfigHiveOn = $true
      }
    }
  }

  if ($Script:IsConfigHiveOn -eq $false) {
    $Script:defaultConfig[$Key] = $Value
  }
  else {
    Set-ConfigValue -Key $Key -Value $Value -HiveName $hiveName -Level Origin
  }
}

function IsPromptEnabled {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  $promptFile = GetConfig('Module.Prompt.DisablePromptFile')
  $fileExists = Test-Path $promptFile
  if ($true -eq $fileExists) {
    Write-Output $false
  }
  else {
    Write-Output $true
  }
}

function CheckLatestPS {
  [CmdletBinding()]
  param()

  $ErrorActionPreference = 'Stop'
  $checkSpanFile = GetConfig('Module.PowerShell.CheckFile')
  $lastCheckFile = GetConfig('Module.PowerShell.LastCheckFile')
  $spanCheck = [TimeSpan] (GetConfig('Module.PowerShell.UpdateCheckTimeSpan'))
  if ((Test-Path $checkSpanFile)) {
    $spanCheck = [TimeSpan] (Import-Clixml -Path $checkSpanFile)
  }

  $checkForVersion = $false
  if (-not (Test-Path $lastCheckFile)) {
    $checkForVersion = $true
  }
  else {
    $lastCheckedTime = [System.DateTime] (Import-Clixml -Path $lastCheckFile)
    $now = Get-Date
    $checkedTimeSpan = $now - $lastCheckedTime
    if ($checkedTimeSpan -gt $spanCheck) {
      $checkForVersion = $true
    }
  }

  if ($true -eq $checkForVersion) {
    $versionComparison = Test-PowerShellVersion
    $m = ("Current PowerShell Version: {0}" -f $versionComparison.Current)
    Print -Message $m
    $m = ("Latest  PowerShell Version: {0}" -f $versionComparison.Latest)
    Print -Message $m
    if ($versionComparison.Latest -gt $versionComparison.Current) {
      Print -Message ('Consider updating to the latest PowerShell (v{0})' -f $versionComparison.Latest) -Accent Yellow
    }

    (Get-Date) | Export-Clixml -Path $lastCheckFile
  }
}

# Expiring cache item trigger types
enum ExpiringCacheItemType {
  TimeSpanTrigger
  CustomTrigger
}
