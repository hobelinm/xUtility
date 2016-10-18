# PsxUtility
> Extended Utilities for PowerShell

**`v1.0.10`**

## What is PsxUtility?
PxsUtility is a project for creating extended Utilities for PowerShell wrapping common functionality on `xUtility` module. 
This module is available for download from the [PowerShell Gallery](https://www.powershellgallery.com/) or from [NPM Registry](https://www.npmjs.com/)

## Available Utilities
- [x] Retry Block with Retry Policy Cmdlet
- [x] Execution block with Expiring Cache Cmdlets.
  - [Add-ExpiringCacheItem](https://github.com/hobelinm/PsxUtility/blob/master/Main/Add-ExpiringCacheItem.ps1)
  - [Get-ExpiringCacheItem](https://github.com/hobelinm/PsxUtility/blob/master/Main/Get-ExpiringCacheItem.ps1)
  - [Remove-ExpiringCacheItem](https://github.com/hobelinm/PsxUtility/blob/master/Main/Remove-ExpiringCacheItem.ps1)
- [x] Custom and Extensible Prompt. 
  - [Set-Prompt](https://github.com/hobelinm/PsxUtility/blob/master/Main/Set-Prompt.ps1)
- [x] Window Title Cmdlets. 
  - [Set-Title](https://github.com/hobelinm/PsxUtility/blob/master/Main/Set-Title.ps1)
- [x] Window Transparency Cmdlet. 
  - [Set-ConsoleTransparency](https://github.com/hobelinm/PsxUtility/blob/master/Main/Set-ConsoleTransparency.ps1)
- [x] Window Resizing Cmdlet. 
  - [Get-WindowSize](https://github.com/hobelinm/PsxUtility/blob/master/Main/Get-WindowSize.ps1)
  - [Set-WindowSize](https://github.com/hobelinm/PsxUtility/blob/master/Main/Set-WindowSize.ps1)
- [x] Admin Detection and Elevation. 
  - [Test-AdminRights](https://github.com/hobelinm/PsxUtility/blob/master/Main/Test-AdminRights.ps1)
  - [Invoke-PSCommand](https://github.com/hobelinm/PsxUtility/blob/master/Main/Invoke-PSCommand.ps1)
- [x] Enable symbolic link behavior. 
  - [Set-SymbolicLinkBehavior](https://github.com/hobelinm/PsxUtility/blob/master/Main/Set-SymbolicLinkBehavior.ps1)
- [x] General utilities. 
  - [Start-SublimeText](https://github.com/hobelinm/PsxUtility/blob/master/Main/Start-SublimeText.ps1)
- [ ] Display formatting cmdlets: Coloring words, rows
- [ ] Automatic module updates, Additional Package Manager(?)

## How to get it:
- [xUtility in the PowerShell Gallery](https://www.powershellgallery.com/packages/xUtility)

`PS> Install-Module -Name xUtility`<br>
`PS> Import-Module -Name xUtility`

- [xUtility in the NPM Registry](https://www.npmjs.com/package/ps-xutilities) via `PsModuleRegister` also found on [NPM](https://www.npmjs.com/package/psmoduleregister)

`PS> npm install -g psmoduleregister`<br>
`PS> psmoduleregister --install ps-xutilities`<br>
`PS> Import-Module -Name xUtility`

## TO DO Items:
- Wrap Out-File calls in the new retry policy cmdlet (Set-Prompt, Set-Title, Set-ConsoleTransparency)
- Implement remaining utilities
- Report upstream logging/analytics from all cmdlets

Additional features will be added over time
