$Script:defaultConfig = @{
  'Module.NoCustomPrompt' = $false
  'Module.IsWindows' = . { isWindows }
  'Module.RetryBlock.PolicyTypeName' = 'System.xUtility.RetryPolicy'
  'Module.RetryBlock.RetryErrorId' = 'RetryLogicLimitReached'
  'Module.Prompt.PolicyName' = 'Random'
  'Module.Prompt.WaitTimeMSecs' = 1000
  'Module.Prompt.RetryTimes' = 3
  'Module.Prompt.CallbackCacheKey' = 'SetPromptCustomCallback'
  'Module.Prompt.CallbackExpiration' = [TimeSpan] '0:0:5'
  'Module.Prompt.CallbackFile' = (. {
    $tmp = Get-TempPath
    $moduleTemp = (Join-Path -Path $tmp -ChildPath 'xUtility')
    if (-not (Test-Path $moduleTemp)) {
      New-Item -ItemType Directory -Path $moduleTemp | Write-Verbose
    }

    $configFile = 'SetPrompt.xml'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.Title.PolicyName' = 'Random'
  'Module.Title.WaitTimeMSecs' = 1000
  'Module.Title.RetryTimes' = 3
  'Module.Title.Config' = (. {
    $tmp = Get-TempPath
    $moduleTemp = (Join-Path -Path $tmp -ChildPath 'xUtility')
    if (-not (Test-Path $moduleTemp)) {
      New-Item -ItemType Directory -Path $moduleTemp | Write-Verbose
    }

    $configFile = 'SetTitle.txt'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.ConsoleTransparency.PolicyName' = 'Random'
  'Module.ConsoleTransparency.WaitTimeMSecs' = 1000
  'Module.ConsoleTransparency.RetryTimes' = 3
  'Module.ConsoleTransparency.DefaultLevel' = 220
  'Module.ConsoleTransparency.Config' = (. {
    $tmp = Get-TempPath
    $moduleTemp = (Join-Path -Path $tmp -ChildPath 'xUtility')
    if (-not (Test-Path $moduleTemp)) {
      New-Item -ItemType Directory -Path $moduleTemp | Write-Verbose
    }

    $configFile = 'ConsoleTransparency.xml'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.ConsoleColorSetTypeName' = 'System.xUtility.ConsoleColorSet'
  'Module.AccentColor' = 'Cyan'
  'Module.WindowsOnlyScripts' = @(
    'Invoke-PSCommand',
    'Set-ConsoleTransparency',
    'Set-SymbolicLinkBehavior',
    'Set-WindowSize',
    'Test-AdminRights'
  )

  'Module.WorkPath' = (. {
    if (isWindows) {
      Write-Output (Join-Path -Path $env:LOCALAPPDATA -ChildPath "xUtility")
    }
    else {
      Write-Output (Join-Path -Path '~/Library/Preferences' -ChildPath 'xUtility')
    }
  })

  'Module.Version' = ([Version] (. {
    $tmp = Get-TempPath
    $moduleTemp = (Join-Path -Path $tmp -ChildPath 'xUtility')
    if (-not (Test-Path $moduleTemp)) {
      New-Item -ItemType Directory -Path $moduleTemp | Write-Verbose
    }
    
    $manifest = Join-Path -Path $Script:ModuleHome -ChildPath 'xUtility.psd1'
    $tmpManifest = Join-Path -Path $moduleTemp -ChildPath 'xUtility.ps1'
    Copy-Item -Path $manifest -Destination $tmpManifest -Force
    $manifestData = . $tmpManifest
    Write-Output $manifestData.ModuleVersion
  }))
}