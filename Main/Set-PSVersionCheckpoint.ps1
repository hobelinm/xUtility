<#
.SYNOPSIS
Sets the time span between checks for newer PowerShell versions

.DESCRIPTION
Takes a time span for checking for newer PowerShell versions. Upon loading, a check for a newer PowerShell version will
be made if the time span between the last time checked and the current time is greater than the set time span

.EXAMPLE
Set-PSVersionCheckpoint -Span '0:0:0'
Will check for a new version of PowerShell every time the module is loaded

.EXAMPLE
Set-PSVersionCheckpoint -Span '-0:0:1'
Will disable checking for newer versions of PowerShell during module load

.EXAMPLE
Set-PSVersionCheckpoint -Span '23:59:59'
Will check for a new version of PowerShell after one day

.NOTES
To check every time the module is loaded use:
[TimeSpan] '0:0:0'

To not check at all, set it to a negative time:
[TimeSpan] '-1:0:0'
#>

function Set-PSVersionCheckpoint {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory)]
    [TimeSpan] $Span
  )

  $ErrorActionPreference = 'Stop'
  $checkFile = GetConfig('Module.PowerShell.CheckFile')
  $Span | Export-Clixml -Path $checkFile
  Print -Message "Set checkpoint span to $Span"
  # TODO: Write telemetry
}
