<#
.SYNOPSIS
	Test current process for administrative rights

.DESCRIPTION
	Test current process for administrative rights

.EXAMPLE
PS> Test-AdminRights
Returns $true when current session has administrative rights and false otherwise

.NOTES
This function is only available in Windows

#>

function Test-AdminRights {
    [CmdletBinding()]
    param()

    $userPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    Write-Output $userPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Set-Alias IsAdmin Test-AdminRights
