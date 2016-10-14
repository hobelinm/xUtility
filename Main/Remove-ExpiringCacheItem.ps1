<#
.SYNOPSIS
	Removes an item from the expiring cache

.DESCRIPTION
	Removes an item from the expiring cache

.EXAMPLE
PS> Remove-ExpiringCacheItem -Key "CachedItem"
Removes the item with the given key from the cache

#>

function Remove-ExpiringCacheItem {
	[CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # Key of the item to remove
        [string] $Key = ""
        )
	
    $ErrorActionPreference = "Stop"
    if (-not $script:expiringCacheObjects.Contains($Key)) {
        Write-Error "An item with key '$Key' does not exist in the cache"
    }

    $script:expiringCacheObjects.Remove($Key)
}
