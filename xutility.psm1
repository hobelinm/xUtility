# Load all cmdlets
$mainFolder = Join-Path -Path $PSScriptRoot -ChildPath "Main"
Get-ChildItem -Filter '*.ps1' -Recurse -Path $mainFolder | ForEach-Object {
    $moduleScript = $_.FullName
    . $moduleScript
}

Write-Verbose "xUtility module is now loaded"
