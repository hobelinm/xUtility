$Script:defaultConfig = @{
  'Module.InlineProgress.BarSize' = 4
  'Module.InlineProgress.Bars' = @('#', '*', '+', '|')
  'Module.PackageVersionUrl' = 'https://raw.githubusercontent.com/hobelinm/PsxUtility/master/package.json'
  'Module.UpdateCheckSpan' = [TimeSpan] '30.00:00:00'
  'Module.VersionTraceFile' = (. {
    $appData = Get-AppDataPath
    $traceFile = Join-Path -Path $appData -ChildPath 'PublishedVersion.xml'
    Write-Output $traceFile
  })
  'Module.NoCustomPrompt' = $false
  'Module.IsWindows' = . { isWindows }
  'Module.RetryBlock.PolicyTypeName' = 'System.xUtility.RetryPolicy'
  'Module.RetryBlock.RetryErrorId' = 'RetryLogicLimitReached'
  'Module.Prompt.FolderSegmentColor' = (. {
    $linuxOs = IsLinux
    if ($linuxOs -eq $false) {
      Write-Output 'DarkGray'
    }
    else {
      Write-Output 'Gray'
    }
  })
  'Module.Prompt.PathSeparatorColor' = (. {
    $linuxOs = IsLinux
    if ($linuxOs -eq $false) {
      Write-Output 'White'
    }
    else {
      Write-Output 'Blue'
    }
  })
  'Module.Prompt.PolicyName' = 'Random'
  'Module.Prompt.WaitTimeMSecs' = 1000
  'Module.Prompt.RetryTimes' = 3
  'Module.Prompt.CallbackCacheKey' = 'SetPromptCustomCallback'
  'Module.Prompt.CallbackExpiration' = [TimeSpan] '0:0:5'
  'Module.Prompt.CallbackFile' = (. {
    $moduleTemp = Get-TempPath
    $configFile = 'SetPrompt.xml'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.Title.PolicyName' = 'Random'
  'Module.Title.WaitTimeMSecs' = 1000
  'Module.Title.RetryTimes' = 3
  'Module.Title.Config' = (. {
    $moduleTemp = Get-TempPath
    $configFile = 'SetTitle.txt'
    $configFile = Join-Path -Path $moduleTemp -ChildPath $configFile
    Write-Output $configFile
  })
  'Module.ConsoleTransparency.PolicyName' = 'Random'
  'Module.ConsoleTransparency.WaitTimeMSecs' = 1000
  'Module.ConsoleTransparency.RetryTimes' = 3
  'Module.ConsoleTransparency.DefaultLevel' = 220
  'Module.ConsoleTransparency.Config' = (. {
    $moduleTemp = Get-TempPath
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

  'Module.Version' = [Version] (. {
    $moduleTemp = Get-TempPath
    $manifest = Join-Path -Path $Script:ModuleHome -ChildPath 'xUtility.psd1'
    $tmpManifest = Join-Path -Path $moduleTemp -ChildPath 'xUtility.ps1'
    Copy-Item -Path $manifest -Destination $tmpManifest -Force
    $manifestData = . $tmpManifest
    Write-Output $manifestData.ModuleVersion
  })
}