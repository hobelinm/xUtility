<#
.SYNOPSIS
    Creates a custom PowerShell prompt
.DESCRIPTION
    Creates a custom PowerShell prompt with the following features:
    - Separates the Current Path $PWD into its own line
    - Allows for quick select of the path
    - Path segments are apart by hightlighted separators
    - Red/Green prompt shows whether the previous operation succeeded or not
    This function allows the arbitrary execution of any script block as an extension mechanism.
    Callbacks can now be persisted so that succeeding session can take advantage of this.

.EXAMPLE
PS> Set-Prompt -Callback { Write-Host "[ x ]" -NoNewLine }
Causes the prompt to execute the given Script Block every time the prompt is updated, producing something like:
[ x ][ C:\Some\User\Directory ]
PS>

.EXAMPLE
PS> Set-Prompt -ClearCallback
Causes the prompt to return to its original state. This operation also removes any persisted callback
[ C:\Some\User\Directory ]
PS>

.EXAMPLE
PS> Set-Prompt -Callback { Write-Host "[ x ]" -NoNewLine } -Persist
Updates the prompt to include the callback code and also saves the callback to disk. When the module is loaded in 
new sessions, their prompt will also include this definition

.NOTES
    Callback code, when persisted, is loaded during Import-Module. If the callback code that is persisted changes
    internally (i.e. other session updated it). Current sessions either have to be restarted or this module would have
    to be Removed (Remove-Module -Name xUtility) and Re-Imported (Import-Module xUtility) for the changes to take effect.
    Create an issue if this behavior is not enough for your needs.
    
    When clearing callback an attempt to delete callback file is also made. To clear the callback from the current session
    but not deleting the callback file simply use:
    Set-Prompt -Callback {}
    Create an issue if this behavior is not enough for your needs.

#>

function Set-Prompt {
    [CmdletBinding(DefaultParameterSetName = "None")]
    param(
        [Parameter(ParameterSetName = "Extended")]
        [ValidateNotNullOrEmpty()]
        # Callback to execute every time the prompt is executed
        [ScriptBlock] $Callback = $null,

        [Parameter(ParameterSetName = "Extended")]
        # Persist the callback to a file so that it can be used in multiple sessions
        [switch] $Persist = $false,

        [Parameter(ParameterSetName = "Clear")]
        # Switch to clear the call of any additional execution context
        [switch] $ClearCallback = $false
        )

    $lastOperationSucceeded = $?
    if ($Callback -ne $null) {
        $Script:extendedPrompt = $Callback
        if ($Persist) {
            # Write Callback to disk
            $Callback.ToString() | Out-File $Script:localSetPromptCallback
        }

        return
    }

    if ($ClearCallback) {
        $Script:extendedPrompt = $null
        if ((Test-Path -Path $Script:localSetPromptCallback)) {
            Remove-Item $Script:localSetPromptCallback
        }

        return
    }

    if ($Script:extendedPrompt -ne $null) {
        . $Script:extendedPrompt
    }

    Write-Host "[ " -ForegroundColor Cyan -NoNewLine
    $PWD.Path.Split('\') | Where-Object { $_ -ne '' } | ForEach-Object {
        Write-Host $_ -NoNewLine -ForegroundColor DarkGray
        Write-Host "\" -NoNewLine -ForegroundColor White
    }

    Write-Host " ]" -ForegroundColor Cyan
    if ($lastOperationSucceeded) {
        Write-Host "PS" -ForegroundColor Green -NoNewLine
    }
    else {
        Write-Host "PS" -ForegroundColor Red -NoNewLine
    }

    "> "
}

Set-Alias Prompt Set-Prompt

# Initialization code
$Script:extendedPrompt = $null
$Script:localSetPromptPath = Join-Path -Path $Script:moduleWorkPath -ChildPath "Set-Prompt"

if (-not (Test-Path $Script:localSetPromptPath)) {
    New-Item -ItemType 'Directory' -Path $Script:localSetPromptPath | Write-Verbose
}

$Script:localSetPromptCallback = Join-Path -Path $Script:localSetPromptPath -ChildPath "callback.txt"
if ((Test-Path $Script:localSetPromptCallback)) {
    $callbackFile = Get-Content $Script:localSetPromptCallback
    $Script:extendedPrompt = [ScriptBlock]::Create($callbackFile)
}
