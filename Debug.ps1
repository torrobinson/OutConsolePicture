 # TEST pull frames
 Add-Type -Assembly 'System.Drawing'
 #$uri = "https://i.imgur.com/Y50DrsD.png"
 #$uri = "https://cdn3.emoji.gg/emojis/7191-hersheyparkspin.gif"
 $uri = "https://cdn3.emoji.gg/emojis/PusheenRice.gif"
 $data = (Invoke-WebRequest $uri).RawContentStream
 $image = New-Object System.Drawing.Bitmap -ArgumentList $data

# Fetch the frame dimensions on this image
$frameDimension = $image.FrameDimensionsList[0];
# Ensure we're using a simple single-dimension image. Todo: look into supporting multiple later
if($image.FrameDimensionsList.Count -gt 1){
    Write-Warning "This does not support frames with different dimensions. Please ensure you only have 1 dimension for all frames."
    exit;
}

# Get the frame count
$frameCount = $image.GetFrameCount($frameDimension);

# Start a collection of frame bitmaps to render
$frameBitmaps = @();

# Read the frames into our frame bitmap array
for($index = 0; $index -lt $frameCount; $index++)
{
    # Go to that frame
    $image.SelectActiveFrame($frameDimension, $index) > $null

    # Add current frame to list
    $frameBitmaps += New-Object System.Drawing.Bitmap -ArgumentList $image;
}


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
$frameDelayInMs = 10;
$playCount = 10;
 
 # Disable the cursor
[console]::CursorVisible = $false

# For each intended playback iteration
foreach($iterationIndex in 0..($playCount-1)){

    # Keep track of which frame we're on this iteration
    $frameIndex = 0

    # For each frame
    foreach ($frameBitmap in $frameBitmaps) {

        # Render the frame
        $frame = New-Object System.Drawing.Bitmap -ArgumentList $frameBitmap
        $frame | Out-ConsolePicture -Align "Center" -Width 32 -AlphaThreshold 100

        # If this isn't the very last frame
        if( ($iterationIndex -lt $playCount-1) -or ($frameIndex -lt $frameCount-1)){

            # Pause in-between frames
            Start-Sleep -Milliseconds $frameDelayInMs

            $rollbackPosition = $Host.UI.RawUI.CursorPosition.Y - ($height / 2);
            if($rollbackPosition -lt 0){
                $rollbackPosition = 0
            }

            # And roll the cursor back to prepare to overwrite the last frame
            [Console]::SetCursorPosition(0, $rollbackPosition) # Divide by two because we use 1 row per 2 pixels
        }

        # Increment frame index
        $frameIndex++
    }

}

 # Enable the cursor
[console]::CursorVisible = $false

"

██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗
██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝
██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  
██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  
╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗
 ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
                                                                                                                                             
".Split([System.Environment]::NewLine,[System.StringSplitOptions]::RemoveEmptyEntries) | %{
	Start-Sleep -Seconds 0.1
	Write-Centered -ForegroundColor Red -Message $_
}
