<#
.SYNOPSIS
	Invokes a PowerShell command

.DESCRIPTION
    Invokes a PowerShell command with the option to
    elevate to an admin process to execute.

.EXAMPLE
PS> Invoke-PSCommand -Command 'dir C:\'
Attempts to execute the given command in the current session

.EXAMPLE
PS> Invoke-PSCommand -Command 'dir C:\' -ElevateIfNeeded
Checks if current user has admin rights, if not will attempt to elevate and execute the command in a 
new session with admin rights

.EXAMPLE
PS> Invoke-PSCommand -Command 'dir C:\' -ElevateIfNeeded -NoExit
Checks if current user has admin rights, if not will attempt to elevate and execute the command in a 
new session with admin rights. After finishing the command the session will be kept open

.EXAMPLE
PS> Invoke-PSCommand -Command 'dir C:\' -ElevateIfNeeded -NoProfile
Checks if current user has admin rights, if not will attempt to elevate and execute the command in a 
new session with admin rights. The new session will not process the contents of the $Profile variable

.NOTES
    If command is executed in the current context, it will be wrapped
    in a ScripBlock object and then executed

    This function is only available in Windows
#>

function Invoke-PSCommand {
	[CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # Command to executed
        [string] $Command = "",

        [Parameter()]
        # Attempt to elevate to a session with admin rights if current one is not admin
        [switch] $ElevateIfNeeded = $false,

        [Parameter()]
        # Keep the session open when attempting to open a new one with admin rights
        [switch] $NoExit = $false,

        [Parameter()]
        # When launching a new session will not process $Profile
        [switch] $NoProfile = $false
        )
    
    $isAdminProcess = Test-AdminRights
    if (-not $ElevateIfNeeded -or $isAdminProcess) {
        . ([ScriptBlock]::Create($Command))
        return
    }

    # If we reach this line:
    # Process is not running as admin and used -ElevateIfNeeded
    # So we need to elevate
    Write-Warning "Attempting to elevate."
    $noExitCommand = ""
    if ($NoExit) {
        $noExitCommand = "-NoExit"
    }

    $noProfileCommand = ""
    if ($NoProfile) {
        $noProfileCommand = "-NoProfile"
    }

    $commandToRun = " $noProfileCommand $noExitCommand -c $Command"

    $powerShellProcess = New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList "PowerShell"
    $powerShellProcess.Arguments = $commandToRun
    $powerShellProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($powerShellProcess)
    if (-not $?) {
        Write-Warning "This script requires administrative privileges. Retry using administrative privileges."
        throw [xUtilityException]::New(
            "Invoke-PSCommand",
            [xUtilityErrorCategory]::InsufficientPermission,
            $_
        )
    }
}

