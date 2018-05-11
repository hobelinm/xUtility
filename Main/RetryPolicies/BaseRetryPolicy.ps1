
# Defines a base Retry Policy. Derived policy objects are expected to implement (override) all methods below
class BaseRetryPolicy {
  # Gets the policy name
  [string] getPolicyName() {
      throw [xUtilityException]::New(
          "BaseRetryPolicy.getPolicyName",
          [xUtilityErrorCategory]::InvalidImplementation,
          "Cannot use an instance of BaseRetryPolicy directly"
      )
  }

  # Get version of the current policy
  [System.Version] getPolicyVersion() {
      throw [xUtilityException]::New(
          "BaseRetryPolicy.getPolicyVersion",
          [xUtilityErrorCategory]::InvalidImplementation,
          "Cannot use an instance of BaseRetryPolicy directly"
      )
  }

  # Determines whether to keep processing the policy or exit
  [bool] shouldProcess([System.Management.Automation.ErrorRecord] $operationError) {
      throw [xUtilityException]::New(
          "BaseRetryPolicy.getRetriesLeft",
          [xUtilityErrorCategory]::InvalidImplementation,
          "Cannot use an instance of BaseRetryPolicy directly"
      )
  }

  # Creates a new instance of the implemented policy
  [BaseRetryPolicy] clone() {
      throw [xUtilityException]::New(
          "BaseRetryPolicy.clone",
          [xUtilityErrorCategory]::InvalidImplementation,
          "Cannot use an instance of BaseRetryPolicy directly"
      )
  }

  # Process the policy
  [void] processPolicy() {
      throw [xUtilityException]::New(
          "BaseRetryPolicy.processPolicy",
          [xUtilityErrorCategory]::InvalidImplementation,
          "Cannot use an instance of BaseRetryPolicy directly"
      )
  }

  # Error Matcher based on
  static [bool] errorMatches(
      [System.Management.Automation.ErrorRecord] $operationError,
      [System.Management.Automation.ErrorRecord[]] $errorReferences,
      [ErrorRecordComparisonType] $comparisonType
  ) {
      $errorMatches = $false
      switch ($comparisonType.ToString()) {
          "NoComparison" { 
              $errorMatches = $true
          }
          
          "TypeCompare" {
              if ($operationError -ne $null) {
                  $errorReferences | Where-Object { -not $errorMatches } | ForEach-Object {
                      $errorReference = $_
                      if ($errorReference.Exception.GetType() -eq $operationError.Exception.GetType()) {
                          $errorMatches = $true
                      }
                  }
              }
          }

          "ActivityCompare" {
              if ($operationError -ne $null) {
                  $errorReferences | Where-Object { -not $errorMatches } | ForEach-Object {
                      $errorReference = $_
                      if ($errorReference.CategoryInfo.Activity -eq $operationError.CategoryInfo.Activity) {
                          $errorMatches = $true
                      }
                  }
              }
          }

          "CategoryCompare" {
              if ($operationError -ne $null) {
                  $errorReferences | Where-Object { -not $errorMatches } | ForEach-Object {
                      $errorReference = $_
                      if ($errorReference.CategoryInfo.Category -eq $operationError.CategoryInfo.Category) {
                          $errorMatches = $true
                      }
                  }
              }
          }

          "IdCompare" {
              if ($operationError -ne $null) {
                  $errorReferences | Where-Object { -not $errorMatches } | ForEach-Object {
                      $errorReference = $_
                      if ($operationError.FullyQualifiedErrorId.Contains($errorReference.FullyQualifiedErrorId)) {
                          $errorMatches = $true
                      }
                  }
              }
          }

          "AnyCompare" {
              $errorMatches = $true
          }

          Default {
              $errorMatches = $false
          }
      }

      return $errorMatches
  }
}
