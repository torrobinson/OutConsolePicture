# This is a script to debug the module during development or testing
# Note: the PS ISE doesn't support ANSI colors, so use your termnial to run this debug script, not ISE itself

# Import the local module. 
# Note: -Force ensures that debugging will use the local version of the script, in case the module is already installed.
Import-Module -Name "$($PSScriptRoot)\OutConsolePicture.psm1" -Force

# Get the internal documentation
#Get-Help Out-ConsolePicture

# Example usage
#Out-ConsolePicture -Url "https://i.imgur.com/tTmm7sA.png" -Width 16 -Align "Right"


# TEMPORARY: Animation playground
$height = 32;
$firstFrame = 1;
$lastFrame = 10;
$frameDelayInMs = 100;
foreach ( $i in $firstFrame..$lastFrame ) {



    # Frame 1: draw a frame
    Out-ConsolePicture -Align "Center" -Width 32 -AlphaThreshold 100 -Url "https://i.imgur.com/Y50DrsD.png" # MARS
    
    # Frame 1: Delay
    Start-Sleep -Milliseconds $frameDelayInMs
    
    # Frame 1: Roll back to start of "canvas"
    [Console]::SetCursorPosition(0, $Host.UI.RawUI.CursorPosition.Y - ($height / 2))




    # Frame 2: draw a frame
     Out-ConsolePicture -Align "Center" -Width 32                     -Url "https://i.imgur.com/tTmm7sA.png"   # RAINBOW
    
    # Frame 2: Delay
    Start-Sleep -Milliseconds $frameDelayInMs
    
    # Frame 2: Roll back to start of "canvas" if it's not the last frame
    if($i -lt $lastFrame){
        [Console]::SetCursorPosition(0, $Host.UI.RawUI.CursorPosition.Y - ($height / 2))
    }
}