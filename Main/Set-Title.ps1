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
PS> Set-Title -NoDefault
Removes the default console title that is set when xUtility is loaded

#>

function Set-Title {
    [CmdletBinding(DefaultParameterSetName = "Title")]
	param(
        [Parameter(ParameterSetName = "Title")]
        [ValidateNotNullOrEmpty()]
        # Message to set the window title to
        [string] $Message,

        [Parameter(ParameterSetName = "Title")]
        # Switch to persist the title to other sessions
        [switch] $Persist = $false,

        [Parameter(ParameterSetName = "Clear")]
        # Removes the default title
        [switch] $NoDefault = $false
        )

    if ($NoDefault) {
        if ((Test-Path $script:localSetTitleMessage)) {
            Remove-Item $script:localSetTitleMessage
        }

        return
    }

    $host.UI.RawUI.WindowTitle = $Message
    if ($Persist) {
        $Message | Out-File $script:localSetTitleMessage
    }
}

# Script initialization
$script:localSetTitlePath = Join-Path -Path $script:moduleWorkPath -ChildPath "Set-Title"

if (-not (Test-Path $script:localSetTitlePath)) {
    New-Item -ItemType 'Directory' -Path $script:localSetTitlePath | Write-Verbose
}

$script:localSetTitleMessage = Join-Path -Path $script:localSetTitlePath -ChildPath "title.txt"
if ((Test-Path $script:localSetTitleMessage)) {
    $host.UI.RawUI.WindowTitle = Get-Content $script:localSetTitleMessage
}
