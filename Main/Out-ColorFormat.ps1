<#
.SYNOPSIS
    Display specific words or rows in given colors

.DESCRIPTION
    Takes a string as input and displays the given words in
    the specified color. Or rows in a series of given colors

.EXAMPLE
PS> $cs = @()
PS> $cs += (New-ConsoleColorSet -ForegroundColor Green)
PS> $cs += (New-ConsoleColorSet -ForegroundColor Yellow)
PS> $cs += (New-ConsoleColorSet -ForegroundColor Red)
PS> $cs += (New-ConsoleColorSet -ForegroundColor White)
PS> dir E:\ | Out-String | % { $_ -split "`r`n" } | ? {$_ -ne ""} | Out-ColorFormat -RowColorSet $cs

Displays the contents of E: in the specified set of row color formants

.EXAMPLE
PS> $colorDict = @{}
PS> $colorDict['AM'] = New-ConsoleColorSet -ForegroundColor Black -BackgroundColor White
PS> $colorDict['PM'] = New-ConsoleColorSet -ForegroundColor White -BackgroundColor Black
PS> $colorDict['dev'] = New-ConsoleColorSet -ForegroundColor Green
PS> $colorDict['repos'] = New-ConsoleColorSet -ForegroundColor Cyan
PS> dir E:\ | Out-String |%{ $_ -split "`r`n" }|?{$_ -ne ""}| Out-ColorFormat -WordColorSet $colorDict

Displays the contents of E: and replaces the format of the words AM, PM, dev, repos with the 
ones specified on the dictionary

#>

function Out-ColorFormat {
    [CmdletBinding(DefaultParameterSetName = "Word")]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Word")]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = "Row")]
        [string] $RawLine = "",

        [Parameter(Mandatory, ParameterSetName = "Row")]
        [ValidateScript({ ValidateRowColorSet -ValidateObject $_ })]
        [PSCustomObject[]] $RowColorSet,

        [Parameter(Mandatory, ParameterSetName = "Word")]
        [ValidateScript({ ValidateWordColorSet -ValidateObject $_ })]
        [HashTable] $WordColorSet
        )
    begin {
        $rowIndex = 0
    }
    
    process { 
        $line = $_
        if ($PsBoundParameters['RawLine']) {
            $line = $RawLine
        }

        if ($PsBoundParameters['RowColorSet'] -ne $null) {
            $whProperties = @{
                Object = $line
            }

            if ($RowColorSet[$rowIndex].ForegroundColor -ne $null) {
                $whProperties['ForegroundColor'] = $RowColorSet[$rowIndex].ForegroundColor
            }
            
            if ($RowColorSet[$rowIndex].BackgroundColor -ne $null) {
                $whProperties['BackgroundColor'] = $RowColorSet[$rowIndex].BackgroundColor
            }

            Write-Host @whProperties
            $rowIndex = $rowIndex + 1
            if ($rowIndex -ge $RowColorSet.Count) {
                $rowIndex = 0
            }
        }
        else {
            while ($line -ne "") {
                # For the given string, get the lowest index of the match words
                $lowestColorIndex = $line.Length
                $lowestColorWord = ""
                $WordColorSet.Keys | ForEach-Object {
                    $colorWord = $_
                    $tentativeIndex = $line.IndexOf($colorWord)
                    if ($tentativeIndex -ne -1 -and $tentativeIndex -lt $lowestColorIndex) {
                        $lowestColorIndex = $tentativeIndex
                        $lowestColorWord = $colorWord
                    }
                    elseif ($tentativeIndex -ne 1 -and 
                        $tentativeIndex -eq $lowestColorIndex -and
                        $colorWord.Length -gt $lowestColorWord.Length) {
                        $lowestColorIndex = $tentativeIndex
                        $lowestColorWord = $colorWord
                    }
                }

                if ($lowestColorWord -eq "") {
                    Write-Verbose "`n[Out-ColorFormat] Couldn't find a match for the dictionary"
                    Write-Host $line -NoNewLine
                    $line = ""
                }
                else {
                    Write-Verbose "`n[Out-ColorFormat] Found '$lowestColorWord' at position '$lowestColorIndex'"
                    # Print normally everything before the first indexof
                    Write-Host -Object $line.Substring(0, $lowestColorIndex) -NoNewLine

                    # Print the matching word in the given format
                    $printData = @{
                        Object = $lowestColorWord
                        NoNewLine = $true
                    }

                    if ($WordColorSet[$lowestColorWord].ForegroundColor -ne $null) {
                        $printData['ForegroundColor'] = $WordColorSet[$lowestColorWord].ForegroundColor
                    }

                    if ($WordColorSet[$lowestColorWord].BackgroundColor -ne $null) {
                        $printData['BackgroundColor'] = $WordColorSet[$lowestColorWord].BackgroundColor
                    }

                    Write-Host @printData

                    # Repeat for the remaining string
                    $line = $line.Substring($lowestColorIndex + $lowestColorWord.Length)
                }
            }

            # New Line and Carriage Return
            Write-Host ""
        }
    }
}

function ValidateRowColorSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]] $ValidateObject
        )

    $ValidateObject | ForEach-Object {
        $lineColorSet = $_
        $colorType = GetConfig('Module.ConsoleColorSetTypeName')
        if ($lineColorSet.PSTypeNames[0] -ne $colorType) {
            throw ("Object of type [{0}] does not correspond to required type {1}" -f 
                $lineColorSet.PSTypeNames[0], $colorType)
        }
    }

    return $true
}

function ValidateWordColorSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [HashTable] $ValidateObject
        )

    if ($ValidateObject.Keys -eq 0) {
        throw "WordColorSet cannot be empty"
    }

    $colorSets = @()
    $ValidateObject.Keys | ForEach-Object {
        $colorSets += $ValidateObject[$_]
    }

    return (ValidateRowColorSet -ValidateObject $colorSets)
}
