# Global variables
$script:moduleWorkPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "xUtility"

<# Console Transparency #>
$script:consoleTransparencyPolicyName = "Random"
$script:consoleTransparencyWaitTime   = 1000
$script:consoleTransparencyRetries    = 3

<# Set Title #>
$script:setTitlePolicyName = "Random"
$script:setTitleWaitTime   = 1000
$script:setTitleRetries    = 3

<# Set Prompt #>
$script:setPromptPolicyName = "Random"
$script:setPromptWaitTime   = 1000
$script:setPromptRetries    = 3

<# Expiring Cache Initialization #>
$script:expiringCacheObjects = @{}

<# Execution with Retry Initialization #>
$script:RetryPolicyTypeName = 'System.xUtility.RetryPolicy'
$script:RetryLogicLimitErrorId = 'RetryLogicLimitReached'

<# Console Color Set Initialization #>
$script:consoleColorSetTypeName = 'System.xUtility.ConsoleColorSet'

# Load all cmdlets
$mainFolder = Join-Path -Path $PSScriptRoot -ChildPath "Main"
Get-ChildItem -Filter '*.ps1' -Recurse -Path $mainFolder | ForEach-Object {
    $moduleScript = $_.FullName
    . $moduleScript
}

Write-Verbose "xUtility module is now loaded"
