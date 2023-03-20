@{

# Script module or binary module file associated with this manifest.
RootModule = 'OutConsolePicture.psm1'

# Version number of this module.
ModuleVersion = '1.5'

# ID used to uniquely identify this module
GUID = '01BE5EE2-E1CF-4E23-B03E-594450ED3F5B'

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Out-ConsolePicture'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Picture','Image','Console','ANSI', 'Graphics'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/torrobinson/OutConsolePicture/'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/torrobinson/OutConsolePicture/releases'

    } # End of PSData hashtable
    
 } # End of PrivateData hashtable

}