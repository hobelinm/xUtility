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
        [Parameter(ParameterSetName = "Clear")]
        # Persist the callback to a file so that it can be used in multiple sessions
        [switch] $Persist = $false,

        [Parameter(ParameterSetName = "Clear")]
        # Switch to clear the call of any additional execution context
        [switch] $ClearCallback = $false
        )

    $lastOperationSucceeded = $?
    
    $joinChar = '\'
    if(-not (GetConfig('Module.IsWindows'))) {
        $joinChar = '/'
        if ($Script:oddPrompt -eq $null) {
            $Script:oddPrompt = $false
        }

        if ($Script:oddPrompt) {
            $Script:oddPrompt = $false
            return
        }
    }

    $callbackKey = GetConfig('Module.Prompt.CallbackCacheKey')
    if ($Callback -ne $null) {
        $p = @{
            'Key'            = $callbackKey
            'ItemDefinition' = $Callback
            'Expiration'     = GetConfig('Module.Prompt.CallbackExpiration')
            'Force'          = $true
        }
    
        Add-ExpiringCacheItem @p
        if ($Persist) {
            # Write Callback to disk
            $promptCallbackFile = GetConfig('Module.Prompt.CallbackFile')
            $p = @{
                'Context'     = { $Callback | Export-Clixml -Path $promptCallbackFile }
                'RetryPolicy' = $Script:setPromptRetryPolicy
            }
            Invoke-ScriptBlockWithRetry @p
        }

        return
    }

    if ($ClearCallback) {
        $p = @{
            'Key'            = $callbackKey
            'ItemDefinition' = { $v = Get-Random }
            'Expiration'     = GetConfig('Module.Prompt.CallbackExpiration')
            'Force'          = $true
        }
    
        Add-ExpiringCacheItem @p
        if ($Persist) {
            $promptCallbackFile = GetConfig('Module.Prompt.CallbackFile')
            if ((Test-Path -Path $promptCallbackFile)) {
                $p = @{
                    'Context'     = { Remove-Item $promptCallbackFile }
                    'RetryPolicy' = $Script:setPromptRetryPolicy
                }
                Invoke-ScriptBlockWithRetry @p
            }
        }

        return
    }

    $val = Get-ExpiringCacheItem -Key $callbackKey
    Write-Host "[ " -ForegroundColor Cyan -NoNewLine
    $folderSegmentColor = GetConfig('Module.Prompt.FolderSegmentColor')
    $pathSeparator = GetConfig('Module.Prompt.PathSeparatorColor')
    $PWD.Path.Split($joinChar) | Where-Object { $_ -ne '' } | ForEach-Object {
        Write-Host $_ -NoNewLine -ForegroundColor $folderSegmentColor
        Write-Host $joinChar -NoNewLine -ForegroundColor $pathSeparator
    }

    Write-Host " ]" -ForegroundColor Cyan
    if ($lastOperationSucceeded) {
        Write-Host "PS" -ForegroundColor Green -NoNewLine
    }
    else {
        Write-Host "PS" -ForegroundColor Red -NoNewLine
    }

    "> "
    
    if(-not (GetConfig('Module.IsWindows'))) {
        $Script:oddPrompt = $true
    }
}

Set-Alias Prompt Set-Prompt

# Initialization code
$p = @{
    'Policy'       = GetConfig('Module.Prompt.PolicyName')
    'Milliseconds' = GetConfig('Module.Prompt.WaitTimeMSecs')
    'Retries'      = GetConfig('Module.Prompt.RetryTimes')
}
$Script:setPromptRetryPolicy = New-RetryPolicy @p

# Checks if there's a prompt change, and update the prompt accordingly
$exPrompt = {
    $callBackFile = GetConfig('Module.Prompt.CallbackFile')
    if ((Test-Path $callBackFile)) {
        $fileRetrieval = {
            Import-Clixml -Path $callBackFile
        }
    
        $p = @{
            'Context'     = $fileRetrieval
            'RetryPolicy' = $Script:setPromptRetryPolicy
        }
        $callbackScript = Invoke-ScriptBlockWithRetry @p
        $executable = [ScriptBlock]::Create($callbackScript)
        . $executable
    }
}

$p = @{
    'Key'            = GetConfig('Module.Prompt.CallbackCacheKey')
    'ItemDefinition' = $exPrompt
    'Expiration'     = GetConfig('Module.Prompt.CallbackExpiration')
    'Force'          = $true
}

Add-ExpiringCacheItem @p
