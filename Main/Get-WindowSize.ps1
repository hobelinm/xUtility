<#
.SYNOPSIS
	Gets the size and buffer size for the current console

.DESCRIPTION
	Returns an object that reflects the size of the current console window
	and the current buffer size
#>

function Get-WindowSize {
	[CmdletBinding()]
	param()

    $currentBuffer = $Host.UI.RawUI.BufferSize 
    $currentWindow = $Host.UI.RawUI.WindowSize 
    Write-Output ([PSCustomObject] @{
        Window = $currentWindow
        Buffer = $currentBuffer
        })
}
