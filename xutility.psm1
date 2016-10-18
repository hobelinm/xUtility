# Global variables
$script:moduleWorkPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "xUtility"

<# Expiring Cache Initialization #>
$script:expiringCacheObjects = @{}

<# Execution with Retry Initialization #>
$script:RetryPolicyTypeName = 'System.xUtility.RetryPolicy'
$script:RetryLogicLimitErrorId = 'RetryLogicLimitReached'

# Load all cmdlets
$mainFolder = Join-Path -Path $PSScriptRoot -ChildPath "Main"
Get-ChildItem -Filter '*.ps1' -Recurse -Path $mainFolder | ForEach-Object {
    $moduleScript = $_.FullName
    . $moduleScript
}

Write-Verbose "xUtility module is now loaded"
