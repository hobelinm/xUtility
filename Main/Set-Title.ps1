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
        [Parameter(ParameterSetName = "Title", Position = 0)]
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

    $titleConfig = GetConfig('Module.Title.Config')
    if ($Clear) {
        if ((Test-Path $titleConfig)) {
            $data = @{
                'Context'     = { Remove-Item $titleConfig }
                'RetryPolicy' = $Script:setTitleRetryPolicy
            }

            Invoke-ScriptBlockWithRetry @data
        }

        $host.UI.RawUI.WindowTitle = $Script:defaultTitle

        return
    }

    $host.UI.RawUI.WindowTitle = $Message
    if ($Persist) {
        $data = @{
            'Context'     = { $Message | Out-File $titleConfig }
            'RetryPolicy' = $Script:setTitleRetryPolicy
        }

        Invoke-ScriptBlockWithRetry @data
    }
}

# Script initialization
$Script:defaultTitle = $host.UI.RawUI.WindowTitle
$data = @{
    'Policy'       = GetConfig('Module.Title.PolicyName')
    'Milliseconds' = GetConfig('Module.Title.WaitTimeMSecs')
    'Retries'      = GetConfig('Module.Title.RetryTimes')
}
$Script:setTitleRetryPolicy = New-RetryPolicy @data

$titleFile = GetConfig('Module.Title.Config')
if ((Test-Path $titleFile)) {
    $fileRetrieval = {
        Get-Content -Path $titleFile
    }

    $data = @{
        'Context'     = $fileRetrieval
        'RetryPolicy' = $Script:setTitleRetryPolicy
    }

    $host.UI.RawUI.WindowTitle = Invoke-ScriptBlockWithRetry @data
}
