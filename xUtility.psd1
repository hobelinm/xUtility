#
# Module manifest for module 'xUtility'
#
# Generated by: Hugo Belin
#
# Generated on: 10/8/2016
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = 'xUtility.psm1'

# Version number of this module.
ModuleVersion = '1.0.7'

# ID used to uniquely identify this module
GUID = '1fa0971d-a634-4176-b4cf-e821b66a5af0'

# Author of this module
Author = 'HugoBelin'

# Company or vendor of this module
CompanyName = 'HugoBelin'

# Copyright statement for this module
Copyright = '(c) 2016 Hugo Belin. See LICENSE for terms.'

# Description of the functionality provided by this module
Description = 'Extended set of utilities for PowerShell'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('xUtility.psm1')

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = @(
    'Get-WindowSize',
    'Invoke-PSCommand',
    'Set-ConsoleTransparency',
    'Set-Prompt', 
    'Set-Title',
    'Set-WindowSize',
    'Start-SublimeText',
    'Test-AdminRights')

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
FileList = @(
    'LICENSE', 
    'README.md', 
    'xUtility.psd1', 
    'xUtility.psm1', 
    'Main\Get-WindowSize.ps1',
    'Main\Invoke-PSCommand.ps1',
    'Main\Set-ConsoleTransparency.ps1',
    'Main\Set-Prompt.ps1', 
    'Main\Set-Title.ps1',
    'Main\Set-WindowSize.ps1',
    'Main\Start-SublimeText.ps1',
    'Main\Test-AdminRights.ps1')

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Utility', 'Console')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/hobelinm/PsxUtility/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/hobelinm/PsxUtility'

        # A URL to an icon representing this module.
        IconUri = 'https://github.com/hobelinm/PsxUtility'

        # ReleaseNotes of this module
        ReleaseNotes = 'Initial Set of Cmdlets'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
HelpInfoURI = 'https://github.com/hobelinm/PsxUtility'

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

