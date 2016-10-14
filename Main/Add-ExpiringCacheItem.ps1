<#
.SYNOPSIS
	PowerShell implementation for Expiring Cache

.DESCRIPTION
	Takes a ScriptBlock as execution and expiration policy.
	ScriptBlock is stored along with its expiration policy.
    Upon access, expiration policy is assessed. On expiration
    the given ScriptBlock is executed and the value is retrieved.
    This value is stored in the cache which is returned until its
    expiration.

.EXAMPLE
PS> Add-ExpiringCacheItem -Key '5sec' -ItemDefinition { Write-Output (Get-Date) } -Expiration '0:0:5'
Adds a script block that is executed every time the cached item expires under the given key

.EXAMPLE
PS> Add-ExpiringCacheItem -Key '5sec' -ItemDefinition { Write-Output (Get-Date) } -Expiration '0:0:5' -Force
Adds a script block that is executed every time the cached item expires under the given key. If an
existing key already exists it gets overwritten

#>

function Add-ExpiringCacheItem {
	[CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # A key to reference this item in the cache
        [string] $Key = "",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # Execution context
        [ScriptBlock] $ItemDefinition,

        [Parameter(Mandatory)]
        # Expiration policy
        [TimeSpan] $Expiration,

        [Parameter()]
        # Whether to override any existing item with same key
        [switch] $Force = $false
        )

    $ErrorActionPreference = "Stop"
    if ($script:expiringCacheObjects.Contains($Key) -and -not $Force) {
        Write-Error "Cache already contains an object with key '$Key'"
    }

    $script:expiringCacheObjects[$Key] = [PSCustomObject] @{
        Expiration     = $Expiration
        ItemDefinition = $ItemDefinition
        Item           = $null
        LastRefresh    = [DateTime] "January 1, 1"
    }
}
