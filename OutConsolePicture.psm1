Add-Type -Assembly 'System.Drawing'

function Out-ConsolePicture {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = "FromPath", Position = 0)]
		[ValidateNotNullOrEmpty()][string[]]
		$Path,
		
		[Parameter(Mandatory = $true, ParameterSetName = "FromWeb")]
		[System.Uri[]]$Url,
		
		[Parameter(Mandatory = $true, ParameterSetName = "FromPipeline", ValueFromPipeline = $true)]
		[System.Drawing.Bitmap[]]$InputObject,
		
		[Parameter()]        
		[int]$Width,

		[Parameter()]
		[switch]$DoNotResize,

		[Parameter()]
		[int]$AlphaThreshold = 255,

		[Parameter()]
		[ValidateSet("Left","Center","Right")]
		[string]$Align = "Left"
	)
	
	begin {
		if ($PSCmdlet.ParameterSetName -eq "FromPath") {
			foreach ($file in $Path) {
				try {
					$image = New-Object System.Drawing.Bitmap -ArgumentList "$(Resolve-Path $file)"
					$InputObject += $image
				}
				catch {
					Write-Error "An error occurred while loading image. Supported formats are BMP, GIF, EXIF, JPG, PNG and TIFF."
				}
			}
		}

		if ($PSCmdlet.ParameterSetName -eq "FromWeb") {
			foreach ($uri in $Url) {
				try {
					$data = (Invoke-WebRequest $uri).RawContentStream    
				}
				catch [Microsoft.PowerShell.Commands.HttpResponseException] {
					if ($_.Exception.Response.statuscode.value__ -eq 302) {
						$actual_location = $_.Exception.Response.Headers.Location.AbsoluteUri
						$data = (Invoke-WebRequest $actual_location).RawContentStream    
					}
					else {
						throw $_
					}                 
				}
				
				try {
					$image = New-Object System.Drawing.Bitmap -ArgumentList $data
					$InputObject += $image
				}
				catch {
					Write-Error "An error occurred while loading image. Supported formats are BMP, GIF, EXIF, JPG, PNG and TIFF."
				}
			}
		}

		if ($Host.Name -eq "Windows PowerShell ISE Host") {
			# ISE neither supports ANSI, nor reports back a width for resizing.
			Write-Warning "ISE does not support ANSI colors."
			Break
		}
		
		# Ignore Align if Width is not set
		if(-not $PSBoundParameters.ContainsKey('Width') -and ($Align -ne "Left")){
			$Align = "Left"
		}

	}
	
	process {
		# Character used to cause a line break
		$line_break_char = "`n"

		# For each image
		$InputObject | ForEach-Object {
			
			# If it's a recognized bitmap
			if ($_ -is [System.Drawing.Bitmap]) {
				
				# Resize image unless explicitly told not to
				if (-not $DoNotResize) {

                    # If we're not given a width, or it's too large set to full width
                    if(-not $width -or ($width -gt $Host.UI.RawUI.BufferSize.Width)){
                        $width = $Host.UI.RawUI.BufferSize.Width;
					}

                    # Perform ratio-safe resize
					$new_height = $_.Height / ($_.Width / $width)
					$resized_image = New-Object System.Drawing.Bitmap -ArgumentList $_, $width, $new_height
					$_.Dispose()
					$_ = $resized_image
				}
                else {
                    # If we can't resize, at least clip the image at the buffer width so we don't overflow it
                    $width = $Host.UI.RawUI.BufferSize.Width;
                }
				
				$all_pixel_pairs = New-Object System.Text.StringBuilder
				
				# For each row of pixels in image
				for ($y = 0; $y -lt $_.Height; $y++) {
					if ($y % 2) {
						# Skip over even rows because we process them in pairs of odds only
						continue
					}
					else {
						if($y -gt 0) {
							# Add linebreaks after every row, if we're not on the first row
							[void]$all_pixel_pairs.append($line_break_char)
						}
					}
					
					# For each pixel (and its corresponding pixel below)
					for ($x = 0; $x -lt [math]::Min($_.Width, $width); $x++) {
						
						# Reset variables
						$fg_transparent, $bg_transparent = $false, $false
						$color_bg, $color_fg = $null, $null
						$pixel_pair = ""
						
						# Determine foreground color and transparency state
						$color_fg = $_.GetPixel($x, $y)
						if($color_fg.A -lt $AlphaThreshold){
							$fg_transparent = $true
						}
						
						# Check if there's even a pixel below to work with
						if (($y + 2) -gt $_.Height) {
							# We are on the last row. There's not.
							# There is no pixel below, and so treat the background as transparent
							$bg_transparent = $true
						}
						else{
							# There is a pixel below
							# Determine background color and transparency state
							$color_bg = $_.GetPixel($x, $y + 1)
							if($color_bg.A -lt $AlphaThreshold){
								$bg_transparent = $true
							}
						}
						
						# If both top/bottom pixels are transparent, just use an empty space as a fully "transparent" pixel pair
						if($fg_transparent -and $bg_transparent){
							$pixel_pair = " "
						}
						# Otherwse determine which to render and which not to render
						else{
							# The two types of characters to use
							$top_half_char = [char]9600	# In which the foreground is on top
							$bottom_half_char = [char]9604 # In which the foreground is on the bottom
							
							# Use the top character as the foreground by default
							$character_to_use = $top_half_char
							
							# If our top character is transparent but bottom isnt, we can't render the foreground as transparent and also have a background.
							if($fg_transparent -and -not $bg_transparent){
								# We need to invert the logic,
								
								# So use the bottom-half char to render instead
								$character_to_use = $bottom_half_char
								
								# Invert the colors
								$color_fg = $color_bg
								
								# Invert the known transparent states
								$fg_transparent = $false
								$bg_transparent = $true
							}
							
							# If the fg (top pixel) is not transparent, give it a character with color
							if(-not $fg_transparent){
								# Draw a foreground
								$pixel_pair += "$([char]27)[38;2;{0};{1};{2}m" -f $color_fg.r, $color_fg.g, $color_fg.b
							}
							# If the bg (bottom pixel) is not transparent, give it a character with color
							if(-not $bg_transparent){
								# Draw a background
								$pixel_pair += "$([char]27)[48;2;{0};{1};{2}m" -f $color_bg.r, $color_bg.g, $color_bg.b
							}
							
							# Add the actual character to render
							$pixel_pair += $character_to_use
							
							# Reset the style to prepare for the next pixel
							$pixel_pair += "$([char]27)[0m"
						}                            

						# Add the pixel-pair to the string builder
						[void]$all_pixel_pairs.Append($pixel_pair)
					}
				}

				# Write the colors to the console based on alignment
				if($Align -eq "Left"){
					# Left is the default
					$all_pixel_pairs.ToString()
				}
				else{
					# Right and Center require padding be added to each line
                    $screen_width = $Host.UI.RawUI.BufferSize.Width;

					if($Align -eq "Right"){
						# Add spaces each line to push to right of buffer
						$padding = $screen_width - $width;
					}
					if($Align -eq "Center"){
						# Add spaces each line to push to center of buffer
						$padding = [math]::ceiling($screen_width / 2) - [math]::ceiling($width / 2);
					}

					# Print each line with required padding
					$all_pixel_pairs.ToString().Split($line_break_char) |% {
						Write-Host (" "*$padding+$_)
					}
				}

				$_.Dispose()
			}
		}
	}

	end {
	}

	<#
.SYNOPSIS
	Renders an image to the console
.DESCRIPTION
	Out-ConsolePicture will take an image file and convert it to a text string. Colors will be "encoded" using ANSI escape strings. The final result will be output in the shell. By default images will be reformatted to the size of the current shell, though this behaviour can be suppressed with the -DoNotResize switch. ISE users, take note: ISE does not report a window width, and scaling fails as a result. I don't think there is anything I can do about that, so either use the -DoNotResize switch, or don't use ISE.
.PARAMETER Path
One or more paths to the image(s) to be rendered to the console.
.PARAMETER Url
One or more Urls for the image(s) to be rendered to the console.
.PARAMETER InputObject
A Bitmap object that will be rendered to the console.
.PARAMETER DoNotResize
By default, images will be resized to have their width match the current console width. Setting this switch disables that behaviour.
.PARAMETER Width
Renders the image at this specific width. Use of the width parameter overrides DoNotResize.
.PARAMETER AlphaThreshold
Default 255; Pixels with an alpha (opacity) value less than this are rendered as fully transparent. Fully opaque = 255. Lowering the value will require a pixel to be more transparent to vanish, and will therefor include more pixels.
.PARAMETER Align
Default 'Left'; Align image to the Left, Right, or Center of the terminal. Must be used in conjuction with the Width parameter.

.EXAMPLE
	Out-ConsolePicture ".\someimage.png"
	Renders the image to console

.EXAMPLE
	Out-ConsolePicture -Url "http://somewhere.com/image.png"
	Renders the image to console

.EXAMPLE
	$image = New-Object System.Drawing.Bitmap -ArgumentList "C:\myimages\image.png"
	$image | Out-ConsolePicture
	Creates a new Bitmap object from a file on disk renders it to the console

.INPUTS
	One or more System.Drawing.Bitmap objects
.OUTPUTS
	The image rendered as console output
#>
}
