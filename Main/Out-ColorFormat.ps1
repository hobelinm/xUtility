<#
.SYNOPSIS
    Display specific words or rows in given colors

.DESCRIPTION
    Takes a string as input and displays the given words in
    the specified color. Or rows in a series of given colors

.EXAMPLE
$cs = @()
$cs += (New-ConsoleColorSet -ForegroundColor Green)
$cs += (New-ConsoleColorSet -ForegroundColor Yellow)
$cs += (New-ConsoleColorSet -ForegroundColor Red)
$cs += (New-ConsoleColorSet -ForegroundColor White)
Windows:
dir E:\ | Out-String | % { $_ -split "`r`n" } | ? {$_ -ne ""} | Out-ColorFormat -FormatDefinition $cs
Mac OS:
dir ~ | Out-String | %{$_ -split "`n"}|?{$_ -ne ''}| Out-ColorFormat -FormatDefinition $cs

Displays the contents of E: in the specified set of row color formants

.EXAMPLE
$colorDict = @()
$colorDict += New-ConsoleColorSet -ForegroundColor Black -BackgroundColor White -Word 'AM'
$colorDict += New-ConsoleColorSet -ForegroundColor White -BackgroundColor Black -Word 'PM'
$colorDict += New-ConsoleColorSet -ForegroundColor Green -Word 'dev'
$colorDict += New-ConsoleColorSet -ForegroundColor Cyan -Word 'Repos'
$colorDict += New-ConsoleColorSet -ForegroundColor Red -Word 'log'
Window:
dir E:\ | Out-String |%{ $_ -split "`r`n" }|?{$_ -ne ""}| Out-ColorFormat -FormatDefinition $colorDict
Mac OS:
dir ~ | Out-String | %{$_ -split "`n"}|?{$_ -ne ''}| Out-ColorFormat -FormatDefinition $colorDict

Displays the contents of E: and replaces the format of the words AM, PM, dev, repos with the 
ones specified on the dictionary

#>

function Out-ColorFormat {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $RawLine = "",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ConsoleColorSet[]] $FormatDefinition
        )
    begin {
        $schemeType = $null
        $wordColorSet = $null
        $rowIndex = 0
    }
    
    process { 
        $line = $_
        if ($PsBoundParameters['RawLine']) {
            $line = $RawLine
        }

        if ($schemeType -eq $null) {
            $schemeType = ValidateFormatDefinition -FormatSet $FormatDefinition
        }

        if ($schemeType -eq [ColorMatchingScheme]::Rows) {
            $whProperties = @{
                'Object' = $line
            }
            
            $lineFormat = $FormatDefinition[$rowIndex]
            if ($lineFormat.SetType -eq [ColorSetType]::Foreground -or 
                $lineFormat.SetType -eq [ColorSetType]::Both) {
                $whProperties['ForegroundColor'] = $lineFormat.ForegroundColor
            }
            
            if ($lineFormat.SetType -eq [ColorSetType]::Background -or 
                $lineFormat.SetType -eq [ColorSetType]::Both) {
                $whProperties['BackgroundColor'] = $lineFormat.BackgroundColor
            }

            Write-Host @whProperties
            $rowIndex = $rowIndex + 1
            if ($rowIndex -ge $FormatDefinition.Count) {
                $rowIndex = 0
            }
        }
        else {
            while ($line -ne "") {
                if ($wordColorSet -eq $null) {
                    $wordColorSet = GetWordSet -FormatSet $FormatDefinition
                }

                # For the given string, get the lowest index of the match words
                $lowestColorIndex = $line.Length
                $lowestColorWord = ""
                $wordColorSet.Keys | ForEach-Object {
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

                    $colorData = $wordColorSet[$lowestColorWord]
                    if ($colorData.SetType -eq [ColorSetType]::Foreground -or
                        $colorData.SetType -eq [ColorSetType]::Both
                    ) {
                        $printData['ForegroundColor'] = $colorData.ForegroundColor
                    }

                    if ($colorData.SetType -eq [ColorSetType]::Background -or
                        $colorData.SetType -eq [ColorSetType]::Both
                    ) {
                        $printData['BackgroundColor'] = $colorData.BackgroundColor
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

enum ColorMatchingScheme {
    Rows
    Words
}

function ValidateFormatDefinition {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ConsoleColorSet[]] $FormatSet
    )

    $matchingType = $null
    $wordList = @{}
    $FormatSet | ForEach-Object { 
        $colorSet = $_
        if ($colorSet.Word -ne [string]::Empty) {
            if ($matchingType -eq $null) {
                $matchingType = ([ColorMatchingScheme]::Words)
            }

            if ($matchingType -ne ([ColorMatchingScheme]::Words)) {
                throw [xUtilityException]::New(
                    "Out-ColorFormat.ValidateFormatDefinition",
                    [xUtilityErrorCategory]::InconsistentMatchingTypes,
                    "All entries have to be matching by the same comparison: rows or words"
                )
            }

            if ($wordList[$colorSet.Word] -ne $null) {
                throw [xUtilityException]::New(
                    "Out-ColorFormat.ValidateFormatDefinition",
                    [xUtilityErrorCategory]::DuplicateMatchingCriteria,
                    "Filtering by word: word to match has to be unique"
                )
            }

            $wordList[$colorSet.Word] = $true
        }
    }

    if ($matchingType -eq $null) {
        $matchingType = ([ColorMatchingScheme]::Rows)
    }
    
    Write-Output $matchingType
}

function GetWordSet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ConsoleColorSet[]] $FormatSet
    )

    $customWordSet = @{}
    $FormatSet | ForEach-Object {
        $colorSet = $_
        $customWordSet[$colorSet.Word] = $colorSet
    }

    Write-Output $customWordSet
}
