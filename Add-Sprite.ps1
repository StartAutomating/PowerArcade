function Add-Sprite
{
    <#
    .Synopsis
        Adds a sprite
    .Description
        Adds a Sprite to the current level, display it for the first time, and register it for collision detection.
    .Example
        # Adds walls surrounding the screen.
        Add-Sprite -X 0 -Y 0 -Width $game.Width -Height 1 -Type Wall # Top
        Add-Sprite -X 0 -Y $game.Height -Width $game.Width -Height 1 -Type Wall # Bottom
        Add-Sprite -X 0 -Y 1 -Width 1 -Height ($game.Height -1) -Type Wall # Left
        Add-Sprite -X $game.Width -Y 1 -Width 1 -Height ($game.Height - 1) -Type Wall #Right
    .Link
        Move-Sprite
    .Link
        New-Sprite
    .Link
        Remove-Sprite
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Games Must Use the Host")]
    [OutputType([Nullable],[PSObject])]
    param(
    # The type of the sprite.  The sprite type is used to group sprites and handle specific collisions.
    [Parameter(Position=0,ValueFromPipelineByPropertyName)]
    [string]
    $Type,

    # The X coordinate of the sprite.
    # If the X coordinate would not be visible, the sprite will not be rendered
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $X,

    # The X coordinate of the sprite.
    # If the Y coordinate would not be visible, the sprite will not be rendered
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Y,

    # The name of the sprite.
    # Giving a sprite a name will declare it as a global variable.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Name,

    # The sprite content.  This can be used for sprites that are a single line.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Content,

    # The sprite color.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Color,

    # The sprite background color.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $BackgroundColor,

    # The width of the sprite.
    # Supplying this and -Height will make the sprite a rectangle.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Width,

    # The height of the sprite
    # Supplying this and -Width will make the sprite a rectangle.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Height,

    # Additional properties of the sprite.
    # This can contain any custom information.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Properties')]
    [Collections.IDictionary]
    $Property,

    # Additional methods for the sprite
    # These can be used to dynamically create sprite behavior.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]
    $Method,

    # If set, this will find randomized empty space to add the sprite.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('WhereEver')]
    [switch]
    $Anywhere,

    # If set, returns the variable of the sprite.
    [Parameter(ValueFromPipelineByPropertyName)]
    [switch]
    $PassThru
    )


    process {
        #region Prepare to Splat
        # Most of the sprite creation is handled by New-Sprite
        $toSplat = @{} + $PSBoundParameters # so copy all parameters
        foreach ($NotToSplat in @('PassThru', 'Anywhere')) { # and remove -PassThru and -Anywhere
            $toSplat.Remove($NotToSplat) # (which are not parameters of New-Sprite)
        }
        #endregion Prepare to Splat

        #region Determine Where anywhere Is
        if ($Anywhere) { # If we want to put a sprite -Anywhere
            $randomizer = [random]::new() # Create a random number
            if ($game.CurrentLevel.SpatialMap.Count) { # If the spatial map has been initialized
                $tryCount = 100 # we'll give it a hundred tries
                $foundASpot = $false # to see if we find a spot.
                :NextSpot do {
                    $X = $randomizer.Next(3,$game.Width - 3) # Pick a random X,Y
                    $Y = $randomizer.Next(3, $game.Height - 3)

                    $coordinates = @(if ($Width -and $Height) { # If provided a -Width and -Height, make a of coordinates
                        for ($ex = $x; $ex -lt ($x + $Width); $ex++) {
                            for ($ey = $y; $ey -lt ($y + $Height); $ey++) {
                                [PSCustomObject]@{X=$ex;Y=$ey}
                            }

                        }
                    } else {
                        [PSCustomObject]@{X=$x;Y=$y}
                    })
                    $tryCount--
                    if ($tryCount -le 0) {
                        break
                    }
                    foreach ($c in $coordinates) { # Walk over each coordinate
                        if (Find-Sprite -X $c.X -Y $c.Y) { # if any sprites were found
                            continue NextSpot # move to the next spot
                            # (this way if the map is cluttered near x,y,
                            # we pick a new spot as soon as we know it's bad)
                        }
                    }
                    $foundASpot = $true # If we made it to here, we've found a spot
                } while (-not $foundASpot)
                if ($tryCount -le 0) {return } # If the try count is depleted, return.
            } else
            {
                # If we didn't have a spatial map yet, just pick a random spot a bit from the edge.
                $X = $randomizer.Next(3, $game.Width - 3)
                $Y = $randomizer.Next(3, $game.Height - 3)
            }

            $toSplat.X = $X
            $toSplat.Y = $y
        }
        #endregion Determine Where anywhere Is

        # Now, create our sprite.
        $newSprite = New-Sprite @toSplat

        if ($Name) # If the sprite was named
        {
            $ExecutionContext.SessionState.PSVariable.Set("Global:$name",$newSprite) # set a global variable
        }

        # If the sprite would be within the field of view, and we're not initializing a level
        if ($newSprite.X -ge 0 -and $newSprite.X -le $Host.UI.RawUI.WindowSize.Width -and
            $newSprite.Y -ge 0 -and $newSprite.Y -le $Host.UI.RawUI.WindowSize.Height -and
            -not $game.CurrentLevel.Initializing
        ) {
            # Write the sprite to the screen.
            [Console]::Write('' + [char]0x1b + '[25l' + (Out-String -InputObject $newSprite -Width 1kb).Trim())
            # (this way, a lot of initial sprite draws can be buffered to improve performance)
        }

        #region Put the Sprite in its Place
        if ($game.CurrentLevel.Sprites.Add) {              # Assuming we have a sprite collection
            $newSpriteSpatialHash = $newSprite.SpatialHash # get the spatial hash of the sprite
            if ($game.CurrentLevel.SpatialMap -and         # If there is a spatial map
                $newSpriteSpatialHash                      # and we have at least one spatial hash
            )
            {
                foreach ($sh in $newSpriteSpatialHash) {   # Walk the spatial hashes
                    # (sprites could be in more than one)

                    # If the spatial hash wasn't already in the map
                    if (-not $game.CurrentLevel.SpatialMap.ContainsKey($sh)) {
                        # they may be off the gamespace and into the ether,
                        # but they may want a world bigger than their screen,
                        # so create a new spatial map bucket.
                        $game.CurrentLevel.SpatialMap[$sh] = [Collections.Generic.List[PSObject]]::new()
                    }
                    # Create a sprite reference.
                    $newSpriteRef =
                        [PSCustomObject]@{PSTypeName='PowerArcade.Sprite.Reference';Type=$type;SpriteID=$newSprite.SpriteID}

                    # Sprite References allow us to safely see the map in terms of a type and ID,
                    # and minimize the data we store.

                    # So we add the sprite reference to the spatial map, so it can be hit.
                    $game.CurrentLevel.SpatialMap[$sh].Add($newSpriteRef)
                }
            }

            $game.CurrentLevel.SpritesById[$newSprite.SpriteID] = $newSprite
            $game.CurrentLevel.Sprites.Add($newSprite)
        }
        #endregion Put the Sprite in its Place

        if (-not $game.CurrentLevel.Sprites.Add -or $PassThru) {
            $newSprite
        }
    }
}