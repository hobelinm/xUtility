<#
.SYNOPSIS
    Sets the PowerShell window Title

.DESCRIPTION
    Sets the PowerShell window Title to the given message. Use -Persist to make this title
    a default for all consoles that load xUtility

.EXAMPLE
PS> Set-Title -Message "Hello World" 
Sets the console title to "Hello World"

.EXAMPLE
PS> Set-Title -Message "Hello World" -Persist
Sets the console title to "Hello World" and make it as default for all sessions that load
xUtility module

.EXAMPLE
PS> Set-Title -Clear
Removes the default console title that is set when xUtility is loaded

#>

function Set-Title {
    [CmdletBinding(DefaultParameterSetName = "Title")]
	param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = "Title")]
        [ValidateNotNullOrEmpty()]
        # Message to set the window title to
        [string] $Message,

        [Parameter(ParameterSetName = "Title")]
        # Switch to persist the title to other sessions
        [switch] $Persist = $false,

        [Parameter(ParameterSetName = "Clear")]
        # Removes the default title
        [switch] $Clear = $false
        )

    if ($Clear) {
        if ((Test-Path $script:localSetTitleMessage)) {
            Invoke-ScriptBlockWithRetry -Context { Remove-Item $script:localSetTitleMessage } -RetryPolicy $script:setTitleRetryPolicy
        }

        $host.UI.RawUI.WindowTitle = "PowerShell"

        return
    }

    $host.UI.RawUI.WindowTitle = $Message
    if ($Persist) {
        Invoke-ScriptBlockWithRetry -Context { $Message | Out-File $script:localSetTitleMessage } -RetryPolicy $script:setTitleRetryPolicy
    }
}

# Script initialization
$script:localSetTitlePath = Join-Path -Path $script:moduleWorkPath -ChildPath "Set-Title"
$script:setTitleRetryPolicy = New-RetryPolicy -Policy $script:setTitlePolicyName -Milliseconds $script:setTitleWaitTime -Retries $script:setTitleRetries

if (-not (Test-Path $script:localSetTitlePath)) {
    New-Item -ItemType 'Directory' -Path $script:localSetTitlePath | Write-Verbose
}

$script:localSetTitleMessage = Join-Path -Path $script:localSetTitlePath -ChildPath "title.txt"
if ((Test-Path $script:localSetTitleMessage)) {
    $fileRetrieval = {
        Get-Content $script:localSetTitleMessage
    }

    $host.UI.RawUI.WindowTitle = Invoke-ScriptBlockWithRetry -Context $fileRetrieval -RetryPolicy $script:setTitleRetryPolicy
}
