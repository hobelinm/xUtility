<#
.SYNOPSIS
	Executes a ScriptBlock with Retry

.DESCRIPTION
	Wraps a ScriptBlock in a try/catch to allow for retrying 
	based on specific exceptions as defined in the retry policy passed.
    To create a retry policy object see New-RetryPolicy cmdlet.

.EXAMPLE
PS> $policy = New-RetryPolicy -Policy Linear -MilliSeconds 1000 -Retries 3
PS> Invoke-ScriptBlockWithRetry -Context { dir Z:\ } -RetryPolicy $policy

Invokes the provided ScriptBlock and will attempt to retry on an exception if it
meets the criteria defined in the policy. The number of retries as well as the 
wait time between retries is also defined in the policy. In this case a linear
retry [1000, 2000, 4000] will the determine the wait time. The provided context
will be attempted 3 times according to the policy defined.

.NOTES
    This cmdlet requires terminating errors to be raised. If your global $ErrorActionPreference is set to 'Continue'
    or 'SilentlyContinue' errors will not be catched. There are a couple of ways to fix this:
    1. Set your global variable to 'Stop':
    PS> $ErrorActionPreference = 'Stop'

    2. Set this preference on the script block commands. i.e. from the example the context to invoke is:
    { dir Z:\ }
    Change this to stop on non-terminating errors as follows:
    { dir Z:\ -ErrorAction Stop}

    See New-RetryPolicy cmdlet for details on policy creation as well as all
    available options.

#>

function Invoke-ScriptBlockWithRetry {
	[CmdletBinding()]
	param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        # Context to execute
        [ScriptBlock] $Context,

        [Parameter(Mandatory)]
        [ValidateScript({ $_.PSTypeNames[0] -eq (GetConfig('Module.RetryBlock.PolicyTypeName')) })]
        # Retry policy determines wait time, whether wait follows any pattern, and the types of exceptions to under which will retry
        $RetryPolicy
        )

    $ErrorActionPreference = 'Stop'
    if ($Global:ErrorActionPreference -ne 'Stop') {
        $Global:ErrorActionPreference = 'Stop'
    }
    
    $continueRetrying = $true
    $retryLogicWorkingSet = $RetryPolicy.WorkingSet.Clone()
    while ($continueRetrying) {
        try {
            . $Context
            $continueRetrying = $false
        }
        catch {
            $e = $_
            if ($e.GetType().Name -eq 'ActionPreferenceStopException') {
                $e = $e.ErrorRecord
            }

            $invokeRetryLogic = $false
            if ($RetryPolicy.ExceptionActivity.Count -eq 0 -and
                $RetryPolicy.ExceptionCategory.Count -eq 0 -and
                $RetryPolicy.ExceptionErrorId.Count -eq 0) {
                # Retry on any error
                $invokeRetryLogic = $true
            }

            $invokeRetryLogic = $invokeRetryLogic -or ($RetryPolicy.ExceptionActivity -contains $e.CategoryInfo.Activity)
            $invokeRetryLogic = $invokeRetryLogic -or ($RetryPolicy.ExceptionCategory -contains $e.CategoryInfo.Category)
            $invokeRetryLogic = $invokeRetryLogic -or ($RetryPolicy.ExceptionErrorId -contains $e.FullyQualifiedErrorId)

            if ($invokeRetryLogic) {
                try {
                    . $RetryPolicy.RetryLogic -WorkingSet $retryLogicWorkingSet
                }
                catch {
                    $e2 = $_
                    $continueRetrying = $false
                    if($e2.GetType().Name -eq 'ActionPreferenceStopException') {
                        $e2 = $e2.ErrorRecord
                    }
                    
                    $retryLimitErrorId = GetConfig('Module.RetryBlock.RetryErrorId')
                    if ($e2.FullyQualifiedErrorId -ne $retryLimitErrorId) {
                        Write-Error -Message ("Error during RetryLogicEvaluation: {0}" -f $e2) -ErrorId 'InvalidRetryLogicEvaluation'
                    }
                    else {
                        Write-Verbose "Reached Retry Limit: $e2"
                        throw $e
                    }
                }
            }
            else {
                Write-Warning 'Retry Logic was not invoked as exception did not passed proper validation'
                $continueRetrying = $false
                throw $e
            }
        }
    }
} 

Set-Alias RetryBlock Invoke-ScriptBlockWithRetry
