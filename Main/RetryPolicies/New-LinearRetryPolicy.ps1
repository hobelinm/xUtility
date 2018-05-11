<#
.SYNOPSIS
    Creates a Linear Retry Policy

.DESCRIPTION
    Creates a new object of type LinearRetryPolicy to be used with Invoke-ScriptBlockWithRetry. The algorithm takes a
    base delay with an optional delay increase, processing this policy will take 
    baseDelay + (delayIncrease x retryCount) milliseconds to complete.
    Constructing a linear retry policy requires also a maximum number of retries mandatory. Once processing the maximum
    number of retries is reached succeeding retries will throw an error of type MaxRetryLimitReached.
    Delay Increase time is optional and if not provided the total delay time is calculated as follows:
    baseDelay + (baseDelay x retryCount)
    Error references can be passed in order to provide filtering on the types of errors to retry or not as well as a 
    comparison type operator which will determine the comparison type to perform. Filtering is done through a method
    named [bool] shouldProcess() which takes a sample error and compares it against the reference. This method is used 
    to determine whether to process the policy or not. shouldProcess method also considers the number of retries already
    performed and compare it agains the retry limit.
    The type of comparison determine the aspects of the sample error to compare agains the references provided. This
    comparison is performed in the base object and the possible behaviors are:
    - NoComparison: Performs no comparison and always returns true
    - TypeCompare: Compares the type of errors to ensure they're the same
    - ActivityCompare: Compares the CategoryInfo.Activity property to ensure are the same
    - CategoryCompare: Compares the CategoryInfo.Category property to ensure are the same
    - IdCompare: Compares the FullyQualifiedErrorId property to ensure sample error contains thew reference's id
    - AnyCompare: Dismiss the comparison and returns true

.EXAMPLE
PS> $retry = New-LinearRetryPolicy -DelayBase 1000 -NumberOfRetries 3
Creates a new retry policy object that starts with a delay of 1 second and will attempt 3 times before throwing an error
with an increase of 1 second between retries (1s, 2s, 3s)

.EXAMPLE
PS> $retry.getPolicyName()
Returns the name of the policy instance

.EXAMPLE
PS> $retry.getPolicyVersion()
Returns the version of the policy instance

.EXAMPLE
PS> $retry.clone()
Returns a new instance of the policy instance using the data of the current object

.EXAMPLE
PS> $retry.shouldProcess($null)
Determines whether the policy should be processed or not based on the sample error provided in comparison to the error
reference objects passed when the object was built

.EXAMPLE
PS> $ex = New-Object ArgumentNullException -ArgumentList "Invalid Argument"
PS> $er = New-Object System.Management.Automation.ErrorRecord -ArgumentList $ex, 'ErrID', 'InvalidArgument', $null
PS> $retry.shouldProcess($er)
Creates a sample Exception and a sample Error Record based of that, then the sample error record is used against the 
retry policy to validate whether to process the policy or not

.EXAMPLE
PS> $retry = New-LinearRetryPolicy -DelayBase 1000 -NumberOfRetries 3
PS> Measure-Command { $retry.processPolicy() }

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 1
Milliseconds      : 15
Ticks             : 10158458
TotalDays         : 1.1757474537037E-05
TotalHours        : 0.000282179388888889
TotalMinutes      : 0.0169307633333333
TotalSeconds      : 1.0158458
TotalMilliseconds : 1015.8458

Creates a sample linear retry policy with initial delay of a second, increments of a second under any error type, and
with 3 attempts

.EXAMPLE
PS> Measure-Command { $retry.processPolicy() }

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 2
Milliseconds      : 0
Ticks             : 20007518
TotalDays         : 2.3156849537037E-05
TotalHours        : 0.000555764388888889
TotalMinutes      : 0.0333458633333333
TotalSeconds      : 2.0007518
TotalMilliseconds : 2000.7518

PS> Measure-Command { $retry.processPolicy() }

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 3
Milliseconds      : 0
Ticks             : 30007282
TotalDays         : 3.4730650462963E-05
TotalHours        : 0.000833535611111111
TotalMinutes      : 0.0500121366666667
TotalSeconds      : 3.0007282
TotalMilliseconds : 3000.7282

Based on the previous example each processing of the policy increases the delay period of a second

.EXAMPLE
PS> $retry.shouldProcess($null)
False
PS> $retry.processPolicy()
[LinearRetryPolicy.invokePolicy:MaxRetryLimitReached] Max number of retries reached: 3/3
At D:\repos\GitHub\PsxUtility\Main\RetryPolicies\New-LinearRetryPolicy.ps1:192 char:13
+             throw [xUtilityException]::New(
+             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : OperationStopped: (:) [], xUtilityException
    + FullyQualifiedErrorId : [LinearRetryPolicy.invokePolicy:MaxRetryLimitReached] Max number of retries reached: 3/3

Based on previous two examples the existing policy object has already reatched the maximum of attempts, hence any
additional retry should fail

.EXAMPLE
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 100
Ticks             : 1007339
TotalDays         : 1.16590162037037E-06
TotalHours        : 2.79816388888889E-05
TotalMinutes      : 0.00167889833333333
TotalSeconds      : 0.1007339
TotalMilliseconds : 100.7339

PS> Measure-Command { $retry.processPolicy() }

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 250
Ticks             : 2502949
TotalDays         : 2.89693171296296E-06
TotalHours        : 6.95263611111111E-05
TotalMinutes      : 0.00417158166666667
TotalSeconds      : 0.2502949
TotalMilliseconds : 250.2949

PS> Measure-Command { $retry.processPolicy() }

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 0
Milliseconds      : 400
Ticks             : 4002831
TotalDays         : 4.63290625E-06
TotalHours        : 0.00011118975
TotalMinutes      : 0.006671385
TotalSeconds      : 0.4002831
TotalMilliseconds : 400.2831

Creates a retry policy with initial delay of 100 milliseconds with increases of 150 milliseconds and 3 retries

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType ActivityCompare
PS> $retry.shouldProcess($null)
False
PS> $es = $null
PS> try{ 5/0 }catch{$es = $_}
PS> $retry.shouldProcess($es)
True

Creates a linear retry policy that is triggered by the comparison on the Activity of a reference error. A null error 
provided did not return a positive match. However a similar error, with the same activity does trigger the match.

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType AnyCompare
PS> $retry.shouldProcess($null)
True
PS> $es = $null
PS> try{ 5/0 }catch{$es = $_}
PS> $retry.shouldProcess($es)
True

Creates a linear retry policy that is triggered with any sample error given the AnyCompare enum value. Both null and a
sample error trigger the match

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType CategoryCompare
PS> $retry.shouldProcess($null)
False
PS> $es = $null
PS> try{ 5/0 }catch{$es = $_}
PS> $retry.shouldProcess($es)
True

Creates a linear retry policy that is triggered with error category match. Null values do not trigger the error while
similar errors do match

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType IdCompare
PS> $retry.shouldProcess($null)
False
PS> Write-Error -Message 'Some Error' -ErrorId 'RuntimeException'
PS> $es = $Error[0]
PS> $retry.shouldProcess($es)
True
PS> Write-Error -Message 'Some Error' -ErrorId 'SomeId'
PS> $es = $Error[0]
PS> $retry.shouldProcess($es)
False

Creates a linear retry policy that is triggered based on the Fully Qualified Id property. Null value does not trigger
the comparison match, while an error with the same ErrorId does trigger the match

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType NoComparison
PS> $retry.shouldProcess($null)
False
PS> Write-Error -Message 'Some Error' -ErrorId 'RuntimeException'
PS> $es = $Error[0]
PS> $retry.shouldProcess($es)
True
PS> Write-Error -Message 'Some Error' -ErrorId 'SomeId'
PS> $es = $Error[0]
PS> $retry.shouldProcess($es)
True

Creates a linear retry policy that is triggered regardles of the object passed since no comparison is made.

.EXAMPLE
PS> $el = $null
PS> try{ 1 / 0 } catch { $el = $_ }
PS> $retry = New-LinearRetryPolicy -DelayBase 100 -DelayIncrease 150 -NumberOfRetries 3 -ErrorReferences @($el)
    -ErrorRecordComparisonType NoComparison
PS> $retry.shouldProcess($null)
False
PS> $es = $null
PS> try{ 5/0 }catch{$es = $_}

Creates a linear retry policy that is triggered when the type of the inner exception matches. It returns false otherwise

#>

function New-LinearRetryPolicy {
  [CmdletBinding()]
  param(
      # Initial delay in milliseconds to start with
      [Parameter(Mandatory)]
      [ValidateScript({$_ -ge 0})]
      [int] $DelayBase = 0,

      # Delay increase in milliseconds
      [Parameter()]
      [ValidateScript({$_ -ge 0})]
      [int] $DelayIncrease = 0,

      # Number of times to retry
      [Parameter(Mandatory)]
      [ValidateScript({$_ -gt 0})]
      [int] $NumberOfRetries = 0,

      # Errors to compare against
      [Parameter()]
      [ValidateNotNullOrEmpty()]
      [System.Management.Automation.ErrorRecord[]] $ErrorReferences = @(),

      # Specify the type of comparison to perform
      [Parameter()]
      [ErrorRecordComparisonType] $ErrorRecordComparisonType = [ErrorRecordComparisonType]::AnyCompare
  )

  $ErrorActionPreference = 'Stop'
  if ($DelayIncrease -eq 0) {
      $DelayIncrease = $DelayBase
  }
  
  return [LinearRetryPolicy]::New(
      $DelayBase, 
      $DelayIncrease, 
      $NumberOfRetries, 
      $ErrorReferences, 
      $ErrorRecordComparisonType)
}

# Implements a linear retry policy
class LinearRetryPolicy : BaseRetryPolicy {
  hidden [int] $RetryCount
  hidden [int] $MaxRetries
  hidden [int] $DelayBaseMs
  hidden [int] $DelayDeltaMs
  hidden [System.Management.Automation.ErrorRecord[]] $ErrorMatches
  hidden [ErrorRecordComparisonType] $ErrorComparisonType

  LinearRetryPolicy(
      # Delay base in milliseconds
      [int] $delayBase, 

      # Increase in delay in milliseconds
      [int] $delayDelta,
      
      # Number of retries to attempt
      [int] $numberOfRetries,
      
      # Errors that will trigger a retry
      [System.Management.Automation.ErrorRecord[]] $errorDetection,
      
      # Types to compare from the errors found
      [ErrorRecordComparisonType] $comparisonType
  ) {
      if ($delayBase -lt 0) {
          throw [xUtilityException]::New(
              "LinearRetryPolicy:BaseRetryPolicy.Constructor",
              [xUtilityErrorCategory]::InvalidParameter,
              "Delay Base (milliseconds) has to be greater or equal to zero"
          )
      }

      if ($delayDelta -lt 0) {
          throw [xUtilityException]::New(
              "LinearRetryPolicy:BaseRetryPolicy.Constructor",
              [xUtilityErrorCategory]::InvalidParameter,
              "Delay Delta (milliseconds) has to be greater or equal to zero"
          )
      }

      if ($numberOfRetries -lt 0) {
          throw [xUtilityException]::New(
              "LinearRetryPolicy:BaseRetryPolicy.Constructor",
              [xUtilityErrorCategory]::InvalidParameter,
              "Number of Retries has to be greater or equal to zero"
          )
      }


      $this.RetryCount = 0
      $this.MaxRetries = $numberOfRetries
      $this.DelayBaseMs  = $delayBase
      $this.DelayDeltaMs = $delayDelta
      $this.ErrorMatches = $errorDetection
      if ($comparisonType -ne $null) {
          $this.ErrorComparisonType = $comparisonType
      }
      else {
          $this.ErrorComparisonType = [ErrorRecordComparisonType]::AnyCompare
      }
  }

  # Gets the policy name
  [string] getPolicyName() {
      return 'LinearRetryPolicy'
  }

  # Get version of the current policy
  [System.Version] getPolicyVersion() {
      return [System.Version] '0.1.0.0'
  }

  # Determines whether to keep processing the policy or exit
  [bool] shouldProcess([System.Management.Automation.ErrorRecord] $operationError) {
      [int] $currentRetryCount = $this.RetryCount + 1
      if ($currentRetryCount -ge $this.MaxRetries) {
          return $false
      }

      return [BaseRetryPolicy]::errorMatches($operationError, $this.ErrorMatches, $this.ErrorComparisonType)
  }

  # Creates a new instance of the implemented policy
  [BaseRetryPolicy] clone() {
      return [LinearRetryPolicy]::New(
          $this.DelayBaseMs,
          $this.DelayDeltaMs,
          $this.MaxRetries,
          $this.ErrorMatches,
          $this.ErrorComparisonType)
  }

  # Process the policy
  [void] processPolicy() {
      if ($this.RetryCount -ge $this.MaxRetries) {
          throw [xUtilityException]::New(
              ("{0}.invokePolicy" -f $this.getPolicyName()),
              [xUtilityErrorCategory]::MaxRetryLimitReached,
              ("Max number of retries reached: {0}/{1}" -f $this.RetryCount, $this.MaxRetries)
          )
      }

      Write-Verbose ("[{0}] Retry {1}/{2} about to sleep {3} milliseconds" -f 
          $this.getPolicyName(),
          $this.RetryCount,
          $this.MaxRetries,
          $this.DelayBaseMs)
      
      Start-Sleep -Milliseconds $this.DelayBaseMs
      $this.DelayBaseMs += $this.DelayDeltaMs
      $this.RetryCount++
  }
}

