<#
.SYNOPSIS
Disables custom prompt for loading

.DESCRIPTION
Creates a file that instructs module loader to skip custom prompt initialization

.EXAMPLE
Disable-CustomPrompt

Disables custom prompt, next time the module is loaded the prompt should not be altered

.EXAMPLE
Disable-CustomPrompt -Restore

Restores custom prompt when loading the module

#>

function Disable-CustomPrompt {
  [CmdletBinding()]
  param(
    # Restores custom prompt when loading the module
    [Parameter()]
    [switch] $Restore = $false
  )

  $ErrorActionPreference = 'Stop'
  $disableFile = GetConfig('Module.Prompt.DisablePromptFile')
  $promptEnabled = IsPromptEnabled
  if ($true -eq $Restore) {
    if ($true -eq $promptEnabled) {
      Print -Message 'Prompt is already enabled. Open a new session for the changes to take effect'
    }
    else {
      Remove-Item -Path $disableFile -Force
      Print -Message 'Prompt has been enabled. Open a new session for the changes to take effect'
    }
  }
  else {
    if ($true -eq $promptEnabled) {
      $true | Export-Clixml -Path $disableFile
      Print -Message 'Prompt has been disabled. Open a new session for the changes to take effect'
    }
    else {
      Print -Message 'Prompt is already disabled. Open a new session for the changes to take effect'
    }
  }

  # TODO: Write telemetry for this function
}
