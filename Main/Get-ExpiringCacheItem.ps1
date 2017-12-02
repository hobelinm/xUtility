<#
.SYNOPSIS
Retrives a value from the local expiring cache

.DESCRIPTION
Retrieves either the cached value, or call the invocation
definition to get a new value, which after being cached is 
returned to the caller

.EXAMPLE
PS> Get-ExpiringCacheItem -Key 'SomeKey'
Retrieves the cached item for the given key, if the cache is expired the cache
is updated with the new definition and returned to the caller

#>

function Get-ExpiringCacheItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # The key to access the cached item
        [string] $Key = ''
        )

    $ErrorActionPreference = 'Stop'
    if (-not $Script:expiringCacheObjects.Contains($Key)) {
        Write-Error "Item with key '$Key' was not found in the cache"
    }

    $cachedItem = $script:expiringCacheObjects[$Key]
    if ($cachedItem.Type -eq [ExpiringCacheItemType]::CustomTrigger) {
        $validation =  . $cachedItem.CustomTrigger
        if ($validation -eq $true) {
            $cachedItem.Item = . $cachedItem.ItemDefinition
            $Script:expiringCacheObjects[$Key] = $cachedItem
        }
    }
    else {
        $now  = Get-Date
        $refreshTime = $cachedItem.LastRefresh + $cachedItem.Expiration
        if ($refreshTime -lt $now) {
            # Need to refresh cache
            $cachedItem.Item = . $cachedItem.ItemDefinition
            $cachedItem.LastRefresh = $now
            $Script:expiringCacheObjects[$Key] = $cachedItem
        }
    }
    
    # Return cached object
    Write-Output $cachedItem.Item
}
