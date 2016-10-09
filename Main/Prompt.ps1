<#
.SYNOPSIS
    Creates a custom PowerShell prompt
.DESCRIPTION
    Creates a custom PowerShell prompt with the following features:
    - Separates the Current Path $PWD into its own line
    - Allows for quick select of the path
    - Path segments are apart by hightlighted separators
    - Red/Green prompt shows whether the previous operation succeeded or not
#>

function Prompt
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string] $Tag = ""
        )

    $lastOperationSucceeded = $?
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