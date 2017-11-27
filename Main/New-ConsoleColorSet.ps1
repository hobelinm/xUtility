<#
.SYNOPSIS
	Creates a color set object. Foreground and background.

.DESCRIPTION
    Creates a pair foreground and background color which
    express a given console format color to use with
    Out-ColorFormat cmdlet.

.EXAMPLE
PS> New-ConsoleColorSet -ForegroundColor Yellow
Returns an object which express a foreground color as Yellow

.EXAMPLE
PS> New-ConsoleColorSet -BackgroundColor Black
Returns an object which express a background color as Black

.EXAMPLE
PS> New-ConsoleColorSet -ForegroundColor Yellow -BackgroundColor Black
Returns an object which express Yellow foreground and black background colors

#>

function New-ConsoleColorSet {
	[CmdletBinding()]
	param(
        [Parameter()]
        [System.ConsoleColor] $ForegroundColor,

        [Parameter()]
        [System.ConsoleColor] $BackgroundColor
        )

    $consoleColorSetTable = @{}
    if ($PsBoundParameters.Keys -contains 'ForegroundColor') {
        $consoleColorSetTable['ForegroundColor'] = $ForegroundColor
    }

    if ($PsBoundParameters.Keys -contains 'BackgroundColor') {
        $consoleColorSetTable['BackgroundColor'] = $BackgroundColor
    }

    $consoleColorSet = [PSCustomObject] $consoleColorSetTable
    $val = GetConfig('Module.ConsoleColorSetTypeName')
    $consoleColorSet.PSTypeNames.Insert(0, $val)
    Write-Output $consoleColorSet
}
