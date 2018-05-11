<#
.SYNOPSIS
    Creates a color set object. Foreground, background with optional word matching.

.DESCRIPTION
    Creates a custom object that defines specifications for using specific foreground and background colors as well as
    any word matching. All parameters are optional, specifying a word will match this combination with the given word,
    otherwise this object will be used for the entire row

.EXAMPLE
PS> New-ConsoleColorSet -ForegroundColor Yellow
Returns an object which express a foreground color as Yellow

.EXAMPLE
PS> New-ConsoleColorSet -BackgroundColor Black
Returns an object which express a background color as Black

.EXAMPLE
PS> New-ConsoleColorSet -ForegroundColor Yellow -BackgroundColor Black
Returns an object which express Yellow foreground and black background colors

.EXAMPLE
PS> New-ConsoleColorSet -Foreground Red -Word 'Error'
Returns an object that will be used to mark the words 'Error' as Red

#>

function New-ConsoleColorSet {
    [CmdletBinding()]
    param(
        [Parameter()]
        [System.ConsoleColor] $ForegroundColor,

        [Parameter()]
        [System.ConsoleColor] $BackgroundColor,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Word = [string]::Empty
        )

    $colorSet = [ConsoleColorSet]::new()
    if ($PsBoundParameters.Keys -contains 'ForegroundColor') {
        $colorSet.ForegroundColor = $ForegroundColor
        $colorSet.SetType = [ColorSetType]::Foreground
    }

    if ($PsBoundParameters.Keys -contains 'BackgroundColor') {
        $colorSet.BackgroundColor = $BackgroundColor
        $colorSet.SetType = [ColorSetType]::Background
    }

    if ($PsBoundParameters.Keys -contains 'ForegroundColor' -and 
        $PsBoundParameters.Keys -ccontains 'BackgroundColor') {
        $colorSet.SetType = [ColorSetType]::Both
    }

    if ($PsBoundParameters.Keys -contains 'Word') {
        $colorSet.Word = $Word
    }
    else {
        $colorSet.Word = [string]::Empty
    }

    Write-Output $colorSet
}

enum ColorSetType {
    Foreground
    Background
    Both
}

class ConsoleColorSet {
    [System.ConsoleColor] $ForegroundColor
    [System.ConsoleColor] $BackgroundColor
    [ColorSetType] $SetType
    [string] $Word
}
