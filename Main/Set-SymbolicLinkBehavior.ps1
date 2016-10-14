<#
.SYNOPSIS
	Sets symbolic link behavior

.DESCRIPTION
	Enables or disable specific symbolic link behavior

.EXAMPLE
PS> Set-SymbolicLinkBehavior -Enable -L2L
Enables symbolic link behavior for the provided behaviors

.EXAMPLE
PS> Set-SymbolicLinkBehavior -Enable -L2L -R2R -L2R -R2L
Enables symbolic link behavior for the provided behaviors

.EXAMPLE
PS> Set-SymbolicLinkBehavior -Disable -L2L -R2R -L2R -R2L
Disables symbolic link behavior for the provided behaviors

.NOTES
    These operations require administrative rights, you can use 
    Invoke-PSCommand to attemt to run this cmdlet with the right
    set of permissions
#>

function Set-SymbolicLinkBehavior {
	[CmdletBinding()]
	param(
        [Parameter(Mandatory, ParameterSetName = "Enable")]
        # Enables symbolic link behavior
        [switch] $Enable = $false,

        [Parameter(Mandatory, ParameterSetName = "Disable")]
        # Disables symbolic link behavior
        [switch] $Disable = $false,

        [Parameter(ParameterSetName = "Enable")]
        [Parameter(ParameterSetName = "Disable")]
        # Left-To-Left follow behavior
        [switch] $L2L = $false,

        [Parameter(ParameterSetName = "Enable")]
        [Parameter(ParameterSetName = "Disable")]
        # Right-To-Right follow behavior
        [switch] $R2R = $false,

        [Parameter(ParameterSetName = "Enable")]
        [Parameter(ParameterSetName = "Disable")]
        # Left-To-Right follow behavior
        [switch] $L2R = $false,

        [Parameter(ParameterSetName = "Enable")]
        [Parameter(ParameterSetName = "Disable")]
        # Right-To-Left follow behavior
        [switch] $R2L = $false
        )

    $ErrorActionPreference = "Stop"
    if (-not (Test-AdminRights)) {
        Write-Error "Administrative privileges are required to perform this operation"
    }

    if ($L2L -and $Enable) {
        fsutil behavior set SymLinkEvaluation L2L:1
    }
    else {
        fsutil behavior set SymLinkEvaluation L2L:0
    }

    if ($R2R -and $Enable) {
        fsutil behavior set SymLinkEvaluation R2R:1
    }
    else {
        fsutil behavior set SymLinkEvaluation R2R:0
    }

    if ($L2R -and $Enable) {
        fsutil behavior set SymLinkEvaluation L2R:1
    }
    else {
        fsutil behavior set SymLinkEvaluation L2R:0
    }

    if ($R2L -and $Enable) {
        fsutil behavior set SymLinkEvaluation R2L:1
    }
    else {
        fsutil behavior set SymLinkEvaluation R2L:0
    }
}
