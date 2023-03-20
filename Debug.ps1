# This is a script to debug the module during development or testing
# Note: the PS ISE doesn't support ANSI colors, so use your termnial to run this debug script, not ISE itself

# Import the local module. 
# Note: -Force ensures that debugging will use the local version of the script, in case the module is already installed.
Import-Module -Name "$($PSScriptRoot)\OutConsolePicture.psm1" -Force

# Get the internal documentation
#Get-Help Out-ConsolePicture

# Example usage
Out-ConsolePicture -Url "https://i.imgur.com/tTmm7sA.png" -Width 16 -Align "Right"