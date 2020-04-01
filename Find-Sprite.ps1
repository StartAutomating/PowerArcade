function Find-Sprite
{
    <#
    .Synopsis
        Finds a Sprite
    .Description
        Finds a Sprite.

        This can find a sprite at a given -X,-Y coordinate,
        or find a sprite within a bounding box (defined by -X,-Width,-Y, and -Height)
        or find a srptie within a given -Radius from -X,-Y
    .Link
        Add-Sprite
    .Link
        Move-Sprite
    .Link
        Remove-Sprite
    .Example
        # Finds sprites in the current game map at 10,20
        Find-Sprite -X 10 -Y 20
    .Example
        # Finds sprites within the current game map at 10,20, or within a 3 pixel radius
        Find-Sprite -X 10 -Y 20 -Radius 3
    #>
    param(
    # The X coordinate to look for a sprite.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $X,

    # The Y coordinate to look for a sprite.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Y,

    # The width of an area in which to look for a sprite.
    # If -Width and -Height are passed, -X and -Y will be treated as the upper left.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Width,


    # The height of an area in which to look for a sprite.
    # If -Width and -Height are passed, -X and -Y will be treated as the upper right.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Height,

    # The radius of the search area.
    # If provided, the -X and -Y will be the center of a virtual square of coordinates
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Radius,

    # If provided, will only find sprites of one or more given types.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $Type
    )

    begin {
        $collided = @()
    }

    process {
        if (-not $game) { return }

        $bounds = @(
            if ($x -ge 0 -and $y -ge 0) {
                if ($Width -and $Height) {
                    # Block
                    for ($ox =0; $ox -lt $Width; $ox++) {
                        for ($oy =0; $oy -lt $Height; $oy++) {
                            [PSCustomObject]@{
                                X = $x + $ox
                                Y = $y + $oy
                                SpatialHash = $game.GetSpatialHash($x + $ox,$y + $oy)
                                PSTypeName='PowerArcade.Point'
                            }
                        }
                    }
                } elseif ($Width) {
                    # Row
                    for ($ox=0;$ox -lt $Width;$ox++) {
                        [PSCustomObject]@{
                            X = $x + $ox
                            Y = $y
                            SpatialHash = $game.GetSpatialHash($x + $ox,$y)
                            PSTypeName='PowerArcade.Point'
                        }
                    }
                } elseif ($Height) {
                    # Column
                    for ($oy=0;$ox -lt $Height;$ox++) {
                        [PSCustomObject]@{
                            X = $x
                            Y = $y + $oy
                            SpatialHash = $game.GetSpatialHash($x,$y + $oy)
                            PSTypeName='PowerArcade.Point'
                        }
                    }
                }
                elseif ($Radius) {
                    # Radius
                    for ($ox = $x - $Radius; $ox -lt ($x + $Radius); $ox++) {
                        for ($oy =$y - $Radius; $oy -lt ($y + $radius); $oy++) {
                            [PSCustomObject]@{
                                X = $ox
                                Y = $oy
                                SpatialHash = $game.GetSpatialHash($ox,$oy)
                                PSTypeName='PowerArcade.Point'
                            }
                        }
                    }
                } else {
                    # Point
                    [PSCustomObject]@{
                        X = $x
                        Y = $y
                        SpatialHash = $game.GetSpatialHash($x,$y)
                        PSTypeName='PowerArcade.Point'
                    }

                }
            }
        )


        :NextBoundsGroup foreach ($boundsGroup in $bounds |
            Group-Object SpatialHash |
            Sort-Object Count -Descending) {

            $spriteList = $game.CurrentLevel.SpatialMap[$boundsGroup.Name]
            :NextBound foreach ($b in $boundsGroup.Group) {
                $boundString = "$($b.X),$($b.Y)"
                :NextSprite foreach ($spriteRef in $spriteList) {
                    $sprite = $game.CurrentLevel.SpritesById[$spriteRef.SpriteID]
                    if ($type) {
                        $typeMatch = $false
                        foreach ($t in $type) {
                            $typeMatch = $typeMatch -bor ($sprite.Type -like $t)
                        }
                        if (-not $typeMatch) { continue NextSprite }
                    }
                    if ($sprite.Bounds -contains $boundString) {
                        # It's a hit!
                        $sprite
                        $collided+=$sprite
                    }
                }
            }
        }



        if (-not $bounds) {
            if ($type -and $game.CurrentLevel.Sprites.Count) {
                :NextSprite foreach ($sprite in $game.CurrentLevel.Sprites) {
                    $typeMatch = $false
                    foreach ($t in $type) {
                        $typeMatch = $typeMatch -bor ($sprite.Type -like $t)
                    }
                    if (-not $typeMatch) { continue NextSprite }
                    $sprite
                }
            }
        }

    }
}
