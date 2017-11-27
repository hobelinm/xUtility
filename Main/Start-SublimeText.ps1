<#
.SYNOPSIS
Opens a given target (file or directory) in Sublime Text

.DESCRIPTION
Opens a given target (file or directory) in Sublime Text.
If Sublime Text installation folder is not found in the system it opens Sublme Text Home Page

.EXAMPLE
PS> sublime 'C:\user\myUserName\Documents'
Opens the specified folder in Sublime Text editor if installed

.EXAMPLE
PS> sublime
Opens Sublime Text editor if installed

.EXAMPLE
PS> sublime 'C:\user\myUserName\Documents\myFile.txt'
Opens the specified file in Sublime Text editor if installed

#>

function Start-SublimeText
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Target = ""
        )

    $ErrorActionPreference = 'Stop'
    $sublimePath = ''
    if (isWindows) {
        $sublimePath = Join-Path -Path $env:ProgramFiles -ChildPath "Sublime Text 3"
        $sublimePath = Join-Path -Path $sublimePath -ChildPath 'subl.exe'
    }
    else {
        $sublimePath = '/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl'
    }

    if (-not (Test-Path $sublimePath)) {
        Start-Process 'http://www.sublimetext.com/3'
        Write-Error '[Start-SublimeText] Sublime Text 3 is not installed on the system'
    }

    . $sublimePath $Target
}

Set-Alias sublime Start-SublimeText
