# Module Error Categories
enum xUtilityErrorCategory {
  CacheKeyNotFound
  InsufficientPermission
  InvalidCacheKey
  InvalidImplementation
  InvalidParameter
  InvalidRetryLogicEvaluation
  MaxRetryLimitReached
}

# Custom error class
class xUtilityException : System.Exception {
  xUtilityException(
    [string] $methodName,
    [xUtilityErrorCategory] $category,
    [string] $message
  ) : base(("[{0}:{1}] {2}" -f $methodName, $category, $message)) {
    # Error message is handled by System.Exception
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
  # TODO:
  # Check if ConfigHive module is available
  # If available check if module config is seeded, if not seed it with default values
  # Use ConfigHive to retrieve data, otherwise use default configuration data
  Write-Output $Script:defaultConfig[$Key]
}


# Expiring cache item trigger types
enum ExpiringCacheItemType {
  TimeSpanTrigger
  CustomTrigger
}
