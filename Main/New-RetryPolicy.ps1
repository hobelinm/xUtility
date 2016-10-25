<#
.SYNOPSIS
	Creates a custom Retry Policy for use with Invoke-ScriptBlockWithRetry
	cmdlet

.DESCRIPTION
	Creates a custom Retry Policy for use with Invoke-ScriptBlockWithRetry.
	Resulting object contains the required information to detect and retry
	appropriately.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Constant -Milliseconds 500 -Retries 5
Creates a retry policy object that will wait a constant time of 500 milliseconds and will allow for 5
retries before throwing a 'RetryLogicLimitReached' exception.

PS> $workSet = $policy.WorkingSet.Clone()
PS> . $policy.RetryLogic -WorkingSet $workSet
Ilustrates the usage of the retry policy to invoke with a constant wait of 500 milliseconds. This 
example can be used 5 times before obtaining 'RetryLogicLimitReached' exception.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Linear -Milliseconds 1000 -Retries 3
Creates a retry policy object that will wait a linear time of 1 second, then 2 seconds, then 3 seconds.
It will allow for 3 attempts before throwing 'RetryLogicLimitReached' exception.

PS> $workSet = $policy.WorkingSet.Clone()
PS> . $policy.RetryLogic -WorkingSet $workSet
Ilustrates the usage of the retry policy to invoke with a linear increment of 1 second. This example
can be used 3 times before throwing 'RetryLogicLimitReached' exception.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Exponential -Milliseconds 100 -Retries 3
Creates a retry policy object that will wait an exponential time of 100 milliseconds and will allow
for 3 executions before throwing 'RetryLogicLimitReached' exception.
The wait sequence in this case is [100ms, 10s, 100 000s]

PS> $workSet = $policy.WorkingSet.Clone()
PS> . $policy.RetryLogic -WorkingSet $workSet
Ilustrates the usage of the retry policy to invoke with an exponential increment of 100 milliseconds. 
This example can be used 3 times before throwing 'RetryLogicLimitReached' exception.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Random -Milliseconds 5000 -Retries 3
Creates a retry policy object that will wait a random time between 0 and 5000 milliseconds and will
allow for 3 attempts before throwing 'RetryLogicLimitReached' exception.

PS> $workSet = $policy.WorkingSet.Clone()
PS> . $policy.RetryLogic -WorkingSet $workSet
Ilustrates the usage of the retry policy to invoke with a random increment of 100 milliseconds. This example
can be used 3 times before throwing 'RetryLogicLimitReached' exception.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Constant -Milliseconds 1000 -Retries 3 -ExceptionActivity 'Write-Error', 'Test-Path'
Creates a retry policy object, with constant wait of 1 second and allows 3 retries before throwing 
'RetryLogicLimitReached'. It records the Exeption.CategoryInfo.Activity to trigger a retry evaluation.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Constant -Milliseconds 1000 -Retries 3 -ExceptionCategory 'NotSpecified'
Creates a retry policy object, with constant wait of 1 second and allows 3 retries before throwing 
'RetryLogicLimitReached'. It records the Exeption.CategoryInfo.Category to trigger a retry evaluation.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Constant -Milliseconds 1000 -Retries 3 -ExceptionErrorId 'MyCustomErrorId'
Creates a retry policy object, with constant wait of 1 second and allows 3 retries before throwing 
'RetryLogicLimitReached'. It records the Exeption.FullyQualifiedErrorId to trigger a retry evaluation.

.EXAMPLE
PS> $customRetryLogic = {
    param([HashTable]$WorkingSet)
    $ErrorActionPreference = 'Stop'
    if($WorkingSet['RetryCount'] -ge $WorkingSet['RetryMax']) {
        Write-Error -Message 'Max RetryReached' -ErrorId 'RetryLogicLimitReached'
    }

    Start-Sleep -Milliseconds 500
    $WorkingSet['RetryCount'] = $WorkingSet['RetryCount'] + 1
}

PS> $workingSet = @{
    RetryCount = 4
    RetryMax = 8
}

PS> $policy = New-RetryPolicy -CustomRetryLogic $customRetryLogic -WorkingSet $workingSet
This example shows how to create a custom retry logic including the required elements such as $WorkingSet required
parameter. Additionally the developer can design and rely on any value on this hashtable provided that the 
developer will add those values to $workingSet hash table. The use of a hash table is optional, for example the global
scope can be used for this, however $WorkingSet parameter should still be provided and the cmdlet will inject an empty
hash table.
Note as well that the FullyQualifiedErrorId of the ErrorRecord or the ActionPreferenceStopException should be always
'RetryLogicLimitReached' for Invoke-ScriptBlockWithRetry to work properly.

.NOTES
    To request additional policy implementations open a new issue in GitHub.
    WorkingSet parameter was introduced to reduce polution on the user scope as
    well as to allow to reuse newly create Retry Policy objects since Execution Retries
    (from Invoke-ScriptBlockWithRetry) will clone this working set and thus start clean every
    time this cmdlet is called with a reused policy object.

#>

function New-RetryPolicy {
	[CmdletBinding(DefaultParameterSetName = "PreDefined")]
	param(
        [Parameter(Mandatory, ParameterSetName = "PreDefined")]
        [ValidateSet("Constant", "Linear", "Exponential", "Random")]
        # Pre-defined Retry Policy to use
        [string] $Policy = "",

        [Parameter(Mandatory, ParameterSetName = "PreDefined")]
        [ValidateScript({ $_ -gt 0})]
        # Delay base between attempts
        [int] $Milliseconds = 0,

        [Parameter(Mandatory, ParameterSetName = "PreDefined")]
        [ValidateScript({$_ -gt 0})]
        # Number of retries
        [int] $Retries = 0,

        [Parameter(Mandatory, ParameterSetName = "UserDefined")]
        [ValidateScript({ ValidateCustomRetryLogic -ValidationTarget $_})]
        # User defined retry policy, parameter -WorkingSet [HashTable] will be passed upon evaluating, so this must be supported
        [ScriptBlock] $CustomRetryLogic = {},

        [Parameter(ParameterSetName = "UserDefined")]
        # Defines any working set memory to hold any state
        [HashTable] $WorkingSet = @{},

        [Parameter(ParameterSetName = "PreDefined")]
        [Parameter(ParameterSetName = "UserDefined")]
        [ValidateNotNullOrEmpty()]
        # Specific Exception.CategoryInfo.Activity to match for retry
        [string[]] $ExceptionActivity = @(),

        [Parameter(ParameterSetName = "PreDefined")]
        [Parameter(ParameterSetName = "UserDefined")]
        [ValidateNotNullOrEmpty()]
        # Specific Exception.CategoryInfo.Category to match for retry
        [string[]] $ExceptionCategory = @(),

        [Parameter(ParameterSetName = "PreDefined")]
        [Parameter(ParameterSetName = "UserDefined")]
        [ValidateNotNullOrEmpty()]
        # Specific Exception.FullyQualifiedErrorId to match for retry
        [string[]] $ExceptionErrorId = @()
        )

    $ErrorActionPreference = "Stop"
    $policyDraft = @{}
    if ($Policy -ne "" -and $Retries -gt 0) {
        $policyDraft['WorkingSet'] = @{
            Retries = $Retries
            RetryCount = 0
            Milliseconds = $Milliseconds
            BaseMilliseconds = $Milliseconds
        }

        # Create retry algorithm here
        switch ($Policy) {
            "Constant" {
                $policyDraft['RetryLogic'] = {
                    param([HashTable] $WorkingSet)

                    $ErrorActionPreference = "Stop"
                    if ($WorkingSet['RetryCount'] -eq $null) {
                        $WorkingSet['RetryCount'] = 0
                    }

                    if ($WorkingSet['RetryCount'] -ge $WorkingSet['Retries']) {
                        Write-Error -Message ("[Constant] RetryCount[{0}] reached the limit of allowed Retries[{1}]" -f $WorkingSet['RetryCount'], $WorkingSet['Retries']) `
                            -ErrorId 'RetryLogicLimitReached'
                    }

                    Write-Verbose ("[Constant] About to sleep {0} Milliseconds" -f $WorkingSet['Milliseconds'])
                    Start-Sleep -Milliseconds $WorkingSet['Milliseconds']
                    $WorkingSet['RetryCount'] = $WorkingSet['RetryCount'] + 1
                }
            }

            "Linear" {
                $policyDraft['RetryLogic'] = {
                    param([HashTable] $WorkingSet)

                    $ErrorActionPreference = "Stop"
                    if ($WorkingSet['RetryCount'] -eq $null) {
                        $WorkingSet['RetryCount'] = 0
                    }

                    if ($WorkingSet['RetryCount'] -ge $WorkingSet['Retries']) {
                        Write-Error -Message ("[Linear] RetryCount[{0}] reached the limit of allowed Retries[{1}]" -f $WorkingSet['RetryCount'], $WorkingSet['Retries']) `
                            -ErrorId 'RetryLogicLimitReached'
                    }

                    Write-Verbose ("[Linear] About to sleep {0} Milliseconds" -f $WorkingSet['Milliseconds'])
                    Start-Sleep -Milliseconds $WorkingSet['Milliseconds']
                    # HashTables are passed as reference, so this will update the caller variable
                    $WorkingSet['Milliseconds'] = $WorkingSet['Milliseconds'] + $WorkingSet['BaseMilliseconds']
                    $WorkingSet['RetryCount'] = $WorkingSet['RetryCount'] + 1
                }
            }

            "Exponential" {
                $policyDraft['RetryLogic'] = {
                    param([HashTable] $WorkingSet)

                    $ErrorActionPreference = "Stop"
                    if ($WorkingSet['RetryCount'] -eq $null) {
                        $WorkingSet['RetryCount'] = 0
                    }

                    if ($WorkingSet['RetryCount'] -ge $WorkingSet['Retries']) {
                        Write-Error -Message ("[Exponential] RetryCount[{0}] reached the limit of allowed Retries[{1}]" -f $WorkingSet['RetryCount'], $WorkingSet['Retries']) `
                            -ErrorId 'RetryLogicLimitReached'
                    }

                    Write-Verbose ("[Exponential] About to sleep {0} Milliseconds" -f $WorkingSet['Milliseconds'])
                    Start-Sleep -Milliseconds $WorkingSet['Milliseconds']
                    # HashTables are passed as reference, so this will update the caller variable
                    $WorkingSet['Milliseconds'] = $WorkingSet['Milliseconds'] + $WorkingSet['Milliseconds']
                    $WorkingSet['RetryCount'] = $WorkingSet['RetryCount'] + 1
                }
            }

            "Random" {
                $policyDraft['RetryLogic'] = {
                    param([HashTable] $WorkingSet)

                    $ErrorActionPreference = "Stop"
                    if ($WorkingSet['RetryCount'] -eq $null) {
                        $WorkingSet['RetryCount'] = 0
                    }

                    if ($WorkingSet['RetryCount'] -ge $WorkingSet['Retries']) {
                        Write-Error -Message ("[Random] RetryCount[{0}] reached the limit of allowed Retries[{1}]" -f $WorkingSet['RetryCount'], $WorkingSet['Retries']) `
                            -ErrorId 'RetryLogicLimitReached'
                    }

                    Write-Verbose ("[Random] About to sleep {0} Milliseconds" -f $WorkingSet['Milliseconds'])
                    Start-Sleep -Milliseconds $WorkingSet['Milliseconds']
                    # HashTables are passed as reference, so this will update the caller variable
                    $WorkingSet['Milliseconds'] = Get-Random -Maximum $WorkingSet['Milliseconds']
                    $WorkingSet['RetryCount'] = $WorkingSet['RetryCount'] + 1
                }
            }

            default {
                throw "Non-implemented Retry Logic"
            }
        }
    }
    else {
        $policyDraft['RetryLogic'] = $CustomRetryLogic
        $policyDraft['WorkingSet'] = $WorkingSet
    }

    $policyDraft['ExceptionActivity'] = $ExceptionActivity
    $policyDraft['ExceptionCategory'] = $ExceptionCategory
    $policyDraft['ExceptionErrorId'] = $ExceptionErrorId

	$retryPolicy = [PSCustomObject] $policyDraft
    $retryPolicy.PSTypeNames.Insert(0, $script:RetryPolicyTypeName)
    Write-Output $retryPolicy
}

# Initialization code

function ValidateCustomRetryLogic {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # ScriptBlock to validate
        [ScriptBlock] $ValidationTarget
        )

    if ($ValidationTarget.Ast.ParamBlock.Parameters.Count -ne 1) {
        throw "Invalid ScriptBlock: Target ScriptBlock does not accept just 1 parameter"
    }

    if ($ValidationTarget.Ast.ParamBlock.Parameters[0].StaticType.ToString() -ne 'System.Collections.Hashtable') {
        throw "Invalid ScriptBlock: Parameter of target ScriptBlock is not of type 'System.Collections.Hashtable'"
    }

    if ($ValidationTarget.Ast.ParamBlock.Parameters[0].Name.ToString() -ne '$WorkingSet') {
        throw "Invalid ScriptBlock: Parameter of target ScriptBlock must be of name '`$WorkingSet'"
    }

    return $true
}
