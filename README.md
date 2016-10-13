# PsxUtility
> Extended Utilities for PowerShell

**`v1.0.5`**

## What is PsxUtility?
PxsUtility is a project for creating extended Utilities for PowerShell wrapping common functionality on `xUtility` module. 
This module is available for download from the [PowerShell Gallery](https://www.powershellgallery.com/) or from [NPM Registry](https://www.npmjs.com/)

## Available Utilities
- [ ] Retry Block with Retry Policy Cmdlet
- [ ] Execution block with Expiring Cache Cmdlet
- [x] Custom and Extensible Prompt
- [x] Window Title Cmdlets
- [x] Window Transparency Cmdlet
- [ ] Window Resizing Cmdlet
- [x] Admin Detection and Elevation

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

Additional features will be added over time
