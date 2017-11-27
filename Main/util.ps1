# Util to determine the OS
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

# Gets temp path according to the host
function Get-TempPath {
  [CmdletBinding()]
  param()

  if (isWindows) {
    Write-Output $env:TEMP
  }
  else {
    Write-Output $env:TMPDIR
  }
}

# Pretty print
function Print {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [string] $Message,

    [Parameter()]
    [System.ConsoleColor] $Accent = (GetConfig('Module.AccentColor')),

    [Parameter()]
    [switch] $NoNewLine = $false
  )

  Write-Host '[' -NoNewline
  Write-Host 'xUtility' -ForegroundColor $Accent -NoNewline
  $caller = (Get-PSCallStack)[1].FunctionName
  if ($caller -ne '<ScriptBlock>') {
    Write-Host '.' -NoNewline
    Write-Host $caller -ForegroundColor $Accent -NoNewline
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
