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

.EXAMPLE
PS> $c={$d=Get-Date;if($d -ge ([DateTime]'12/1/17 11:11:00 PM')){Write-Output $true}else{Write-Output $false}}
PS> Add-ExpiringCacheItem -Key '5sec2' -ItemDefinition { Write-Output (Get-Date).ToString() } -CustomTrigger $c
Creates a custom ScriptBlock, in this case returns true after the specified time, before this the cache is $null
this value is returned back from the call

#>

function Add-ExpiringCacheItem {
    [CmdletBinding(DefaultParameterSetName = 'TimeSpan')]
    param(
        # A key to reference this item in the cache
        [Parameter(Mandatory, ParameterSetName = 'TimeSpan')]
        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateNotNullOrEmpty()]
        [string] $Key = '',

        # Execution context
        [Parameter(Mandatory, ParameterSetName = 'TimeSpan')]
        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateNotNullOrEmpty()]
        [ScriptBlock] $ItemDefinition,

        # Expiration policy
        [Parameter(Mandatory, ParameterSetName = 'TimeSpan')]
        [TimeSpan] $Expiration = '0:0:0',

        # Custom execution script to determine when to refresh the cache
        [Parameter(Mandatory, ParameterSetName = 'Custom')]
        [ValidateNotNull()]
        [ScriptBlock] $CustomTrigger = $null,
        
        # Whether to override any existing item with same key
        [Parameter(ParameterSetName = 'TimeSpan')]
        [Parameter(ParameterSetName = 'Custom')]
        [switch] $Force = $false
        )

    $ErrorActionPreference = 'Stop'
    if ($script:expiringCacheObjects.Contains($Key) -and -not $Force) {
        throw [xUtilityException]::New(
            'Add-ExpiringCacheItem',
            [xUtilityErrorCategory]::InvalidCacheKey,
            "Cache already contains an object with key '$Key'"
        )
    }

    $cacheType = GetConfig('Module.ExpiringCache.CacheType')
    $triggerType = [ExpiringCacheItemType]::TimeSpanTrigger
    if ($CustomTrigger -ne $null) {
        $triggerType = [ExpiringCacheItemType]::CustomTrigger
    }

    $cacheItem = [PSCustomObject] @{
        Expiration     = $Expiration
        ItemDefinition = $ItemDefinition
        Item           = $null
        LastRefresh    = [DateTime] "January 1, 1"
        CustomTrigger  = $CustomTrigger
        Type           = $triggerType
    }

    $cacheItem.PSTypeNames.Insert(0, $cacheType)
    $script:expiringCacheObjects[$Key] = $cacheItem
}
