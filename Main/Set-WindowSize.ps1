<#
.SYNOPSIS
    Sets the current console window to a specified size

.DESCRIPTION
    Sets the current console window to a specified size.
    Alternatively it can be maximized.

.EXAMPLE
PS> Set-WindowSize -Height 60 -Width 130
Sets the console window to the given dimensions

.EXAMPLE
PS> Set-WindowSize -Maximize
Sets the console window to the maximum size available

.NOTES
    When downsizing the contents of the buffer are flushed. If there's content wider thant the
    target content, it will be lost

#>

function Set-WindowSize {
	[CmdletBinding(DefaultParameterSetName = "MaxSize")]
	param(
        [Parameter(Mandatory, ParameterSetName = "CustomSize")]
        [ValidateScript({ $_ -gt 0})]
        # Target Height
        [int] $Height = 50,

        [Parameter(Mandatory, ParameterSetName = "CustomSize")]
        [ValidateScript({ $_ -gt 0})]
        # Target Width
        [int] $Width = 120,

        [Parameter(ParameterSetName = "MaxSize")]
        # Maximize the window
        [switch] $Maximize = $false
        )
	
    $maxHeight = $Host.UI.RawUI.MaxPhysicalWindowSize.Height 
    $maxWidth = $Host.UI.RawUI.MaxPhysicalWindowSize.Width 
    if ($Maximize) {
        $Height = $maxHeight
        $Width  = $maxWidth - 2
    }

    $consoleBuffer = $Host.UI.RawUI.BufferSize 
    $consoleWindow = $Host.UI.RawUI.WindowSize 
 
    $consoleWindow.Height = ($Height) 
    $consoleWindow.Width = ($Width) 

    #$consoleBuffer.Height = (9999)
    $consoleBuffer.Height = (9000)
    $consoleBuffer.Width = ($Width) 

    $Host.UI.RawUI.FlushInputBuffer()
    $Host.UI.RawUI.set_bufferSize($consoleBuffer) 
    $Host.UI.RawUI.set_windowSize($consoleWindow) 
}
