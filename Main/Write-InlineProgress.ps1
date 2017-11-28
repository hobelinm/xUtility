<#
.SYNOPSIS
Writes inline progress

.DESCRIPTION
Writes inline progress messages. This is designed to display multiple progress messages in the same line

.EXAMPLE
$p = { [PSCustomObject] @{ 'Header' = 'MyProcess'; 'Message' = ("Evaluating: {0}" -f $_); 'Percentage' = $_ } }
1..100 |%{Start-Sleep -Milliseconds 100; Write-Output $_}| % $p | Write-InlineProgress

Writes a series of messages in the same line

.EXAMPLE
$p = { [PSCustomObject] @{ 'Header' = 'MyProcess'; 'Message' = ("Evaluating: {0}" -f $_) } }
1..1000 | % $p | Write-InlineProgress

Writes a series of messages in the same line without controlling the percentage

.EXAMPLE
1..150 |%{Start-Sleep -Milliseconds 100; Write-Output $_}|Write-InlineProgress -Header 'Proc'

Writes a series of messages all of them using the same header, global percentage is used

.EXAMPLE
Write-InlineProgress -Header 'MyProcess' -Message 'Processing'

Writes an inline progress message with header, a global percentage is used

.EXAMPLE 
Write-InlineProgress -Message 'Processing'

Writes a simple inline message, a global percentage is used

#>

function Write-InlineProgress {
  [CmdletBinding()]
  param(
    # Header to append the message
    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string] $Header = [string]::Empty,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [string] $Message,

    [Parameter(ValueFromPipelineByPropertyName)]
    [ValidateScript({ $_ -ge 0 -and $_ -le 100 })]
    [int] $Percentage = -1
  )

  begin {
    $ErrorActionPreference = 'Stop'
    $currentPosition = $Host.UI.RawUI.CursorPosition
    $windowSize = $Host.UI.RawUI.WindowSize
    $bars = GetConfig('Module.InlineProgress.Bars')
    if ($Script:WriteInlineProgressIdx -eq $null) {
      $Script:WriteInlineProgressIdx = 0
    }

    if ($Script:WriteInlineProgressVirtualPercentage -eq $null) {
      $Script:WriteInlineProgressVirtualPercentage = 0
    }

    $progressBarSize = GetConfig('Module.InlineProgress.BarSize')
    $accentColor = GetConfig('Module.AccentColor')
  }

  process {
    if ($Percentage -ne -1) {
      $Script:WriteInlineProgressVirtualPercentage = $Percentage
    }

    # Cleanup line
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $currentPosition.Y
    Write-Host (' ' * ($windowSize.Width - 1)) -NoNewline
    $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0, $currentPosition.Y
    # Print Progress bar
    Write-Host '[' -NoNewline -ForegroundColor White
    $barLength = [int] (($Script:WriteInlineProgressVirtualPercentage * $progressBarSize) / 99)
    Write-Host ($bars[$Script:WriteInlineProgressIdx] * $barLength) -NoNewline -ForegroundColor $accentColor
    Write-Host (' ' * ($progressBarSize - $barLength)) -NoNewline
    Write-Host ']' -NoNewline -ForegroundColor White
    # Print Percentage
    $percentageDigits = ("{0}" -f $Script:WriteInlineProgressVirtualPercentage).Length
    Write-Host (" " * (3 - $percentageDigits)) -NoNewline
    Write-Host $Script:WriteInlineProgressVirtualPercentage -NoNewline -ForegroundColor White
    Write-Host '% ' -NoNewline -ForegroundColor $accentColor
    # Calculate space left for message
    $spaceTaken = $progressBarSize + 2 + 5
    if ($Header -ne [string]::Empty) {
      $spaceTaken = $spaceTaken + $Header.Length + 3
    }

    $subMsg = $Message
    if ($Message.Length -ge ($windowSize.Width - $spaceTaken)) {
      $subMsg = $subMsg.Substring(0, ($windowSize.Width - $spaceTaken - 3))
      $subMsg = "$subMsg..."
    }

    # Print Header
    if ($Header -ne [string]::Empty) {
      Print -Header $Header -Message $subMsg -NoNewline
    }
    else {
      Write-Host $subMsg -NoNewline
    }

    if (($Script:WriteInlineProgressVirtualPercentage + 1) -eq 100) {
      # Shift indicator
      $Script:WriteInlineProgressIdx = ($Script:WriteInlineProgressIdx + 1) % $bars.Count
    }

    $Script:WriteInlineProgressVirtualPercentage = ($Script:WriteInlineProgressVirtualPercentage + 1) % 101
  }

  end {
    Write-Host ""
  }
}
