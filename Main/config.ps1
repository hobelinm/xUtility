$Script:defaultConfig = @{
  'Module.PowerShell.LastCheckFile' = (. {
    $appData = GetAppDataPath
    $checkFile = Join-Path -Path $appData -ChildPath 'LastPSCheck.xml'
    Write-Output $checkFile
  })
  'Module.PowerShell.CheckFile' = (. {
    $appData = GetAppDataPath
    $checkFile = Join-Path -Path $appData -ChildPath 'PSCheckTimeSpan.xml'
    Write-Output $checkFile
  })
  'Module.PowerShell.Core.RequestHeaders' = @{'Accept' = 'application/vnd.github.v3+json'}
  'Module.PowerShell.Core.LatestVersionSource' = 'https://api.github.com/repos/PowerShell/PowerShell/releases/latest'
  'Module.PowerShell.UpdateCheckTimeSpan' = [TimeSpan] '30.00:00:00'
  'Module.Config.HiveName' = 'xUtility'
  'Module.ExpiringCache.CacheType' = 'System.xUtility.ExpiringCache'
  'Module.InlineProgress.BarSize' = 4
  'Module.InlineProgress.Bars' = @('#', '*', '+', 'o')
  'Module.PackageVersionUrl' = 'https://raw.githubusercontent.com/hobelinm/xUtility/master/package.json'
  'Module.UpdateCheckSpan' = [TimeSpan] '30.00:00:00'
  'Module.VersionTraceFile' = (. {
    $appData = GetAppDataPath
    $traceFile = Join-Path -Path $appData -ChildPath 'PublishedVersion.xml'
    Write-Output $traceFile
  })
  'Module.NoCustomPrompt' = $false
  'Module.IsWindows' = . { isWindows }
  'Module.RetryBlock.PolicyTypeName' = 'System.xUtility.RetryPolicy'
  'Module.RetryBlock.RetryErrorId' = 'RetryLogicLimitReached'
  'Module.Prompt.DisablePromptFile' = (. {
    $appData = GetAppDataPath
    $promptFile = Join-Path -Path $appData -ChildPath 'NoPromptFile.xml'
    Write-Output $promptFile
  })
  'Module.Prompt.FolderSegmentColor' = (. {
    $linuxOs = IsLinux
    if ($linuxOs -eq $false) {
      Write-Output 'DarkGray'
    }
    else {
      Write-Output 'Gray'
    }
  })
  'Module.Prompt.PathSeparatorColor' = 'White'
  'Module.Prompt.PolicyName' = 'Random'
  'Module.Prompt.WaitTimeMSecs' = 1000
  'Module.Prompt.RetryTimes' = 3
  'Module.Prompt.CallbackCacheKey' = 'SetPromptCustomCallback'
  'Module.Prompt.CallbackExpiration' = [TimeSpan] '0:0:5'
  'Module.Prompt.CallbackFile' = (. {
    $moduleTemp = GetTempPath
    $configFile = 'SetPrompt.xml'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.Title.PolicyName' = 'Random'
  'Module.Title.WaitTimeMSecs' = 1000
  'Module.Title.RetryTimes' = 3
  'Module.Title.Config' = (. {
    $moduleTemp = GetTempPath
    $configFile = 'SetTitle.txt'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.ConsoleTransparency.PolicyName' = 'Random'
  'Module.ConsoleTransparency.WaitTimeMSecs' = 1000
  'Module.ConsoleTransparency.RetryTimes' = 3
  'Module.ConsoleTransparency.DefaultLevel' = 220
  'Module.ConsoleTransparency.Config' = (. {
    $moduleTemp = GetTempPath
    $configFile = 'ConsoleTransparency.xml'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.ConsoleColorSetTypeName' = 'System.xUtility.ConsoleColorSet'
  'Module.AccentColor' = 'Cyan'
  'Module.WindowsOnlyScripts' = @(
    'Invoke-PSCommand.ps1',
    'Set-ConsoleTransparency.ps1',
    'Set-SymbolicLinkBehavior.ps1',
    'Set-WindowSize.ps1',
    'Test-AdminRights.ps1'
  )

  'Module.WorkPath' = (. {
    if (isWindows) {
      Write-Output (Join-Path -Path $env:LOCALAPPDATA -ChildPath "xUtility")
    }
    else {
      Write-Output (Join-Path -Path '~/Library/Preferences' -ChildPath 'xUtility')
    }
  })

  'Module.Version' = [Version] (. {
    $moduleTemp = GetTempPath
    $manifest = Join-Path -Path $Script:ModuleHome -ChildPath 'xUtility.psd1'
    $tmpManifest = Join-Path -Path $moduleTemp -ChildPath 'xUtility.ps1'
    Copy-Item -Path $manifest -Destination $tmpManifest -Force
    $manifestData = . $tmpManifest
    Write-Output $manifestData.ModuleVersion
  })
}
