function Move-Sprite
{
    <#
    .Synopsis
        Moves sprites
    .Description
        Moves sprites around the screen
    .Example
        $dot | Move-Sprite -X 10 -Y 20
    .Link
        Add-Sprite
    .Link
        Find-Sprite
    .Link
        New-Sprite
    .Link
        Remove-Sprite
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Games Must Use the Host")]
    [OutputType([Nullable],[PSObject])]
    param(
    # The Sprite
    [Parameter(Mandatory,ValueFromPipeline)]
    [PSTypeName('PowerArcade.Sprite')]
    [PSObject]
    $Sprite,

    # The target X coordinate
    [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName)]
    [int]
    $X,

    # The target Y coordinate
    [Parameter(Mandatory,Position=1,ValueFromPipelineByPropertyName)]
    [int]
    $Y,

    # If set, will not clear the content at the old sprite position
    [Alias('DoNotClear')]
    [switch]
    $NoClear,

    # If set, will force an overwrite in the case of a collision.
    [switch]
    $Force
    )

    process {
        # It's possible the sprite doesn't have an X/Y yet, so add it if they don't.
        if (-not $sprite.psobject.properties['X']) {
            $sprite.psobject.properties.Add([PSNoteProperty]::new('X',$X))
        }
        if (-not $sprite.psobject.properties['Y']) {
            $sprite.psobject.properties.Add([PSNoteProperty]::new('Y',$Y))
        }

        #region Where am I going, and who will I run into there?
        $newBounds = $Sprite.MeasureBounds($x, $y)

        $collision = $false
        $foundSprites = $newBounds |Find-Sprite
        if ($foundSprites) {
            $null = $null
            foreach ($ThingIHit in $foundSprites) {
                if ($ThingIHit -eq $Sprite) { continue }
                $collision = $true
                if ($sprite.'+'.Invoke) {
                    $sprite.'+'($ThingIHit)
                }
                if ($sprite."+$($ThingIHit.Type)".Invoke) {
                    $sprite."+$($ThingIHit.Type)"($ThingIHit)
                }
            }
        }
        #region Where am I going, and who will I run into there?

        if ($collision -and -not $Force) {
            return
        }


        try {[Console]::CursorVisible = $false} catch {$PSCmdlet.WriteVerbose("$_")} 
        if (-not $NoClear -and -not $this.Hidden) {
            [Console]::Write("$($Sprite.Clear())".Trim())
        }

        $oldBounds = $Sprite.MeasureBounds()

        $sprite.X, $sprite.Y = $X, $Y

        $newSpatialHashes = $newBounds | Select-Object -ExpandProperty SpatialHash -Unique
        $oldSpatialHashes = $oldBounds | Select-Object -ExpandProperty SpatialHash -Unique

        foreach ($nsh in $newSpatialHashes) {
            if ($oldSpatialHashes -notcontains $nsh) { # Moving into a new spatial hash
                if ($game.CurrentLevel.SpatialMap.ContainsKey($nsh)) {
                    $game.CurrentLevel.SpatialMap[$nsh].Add(
                        [PSCustomObject]@{PSTypeName='PowerArcade.Sprite.Reference';Type=$sprite.type;SpriteID=$sprite.SpriteID}
                    )

                    $game.CurrentLevel.SpritesById[$sprite.SpriteID] = $sprite
                }
            }
        }

        foreach ($osh in $oldSpatialHashes) {
            if ($newSpatialHashes -notcontains $osh) { # Moving out of an old spatial hash
                if ($game.CurrentLevel.SpatialMap.ContainsKey($osh)) {
                    $toRemove =
                        for ($in =0 ; $in -lt $game.CurrentLevel.SpatialMap[$osh].Count; $in++) {
                            if ($game.CurrentLevel.SpatialMap[$osh][$in].SpriteID -eq $Sprite.SpriteID) {
                                $game.CurrentLevel.SpatialMap[$osh][$in]
                                break
                            }
                        }

                    foreach ($tr in $toRemove) {
                        $null = $game.CurrentLevel.SpatialMap[$osh].Remove($tr)
                    }
                }
            }
        }
        if (-not $this.Hidden -and
            $game.CurrentLevel.SpriteMap.ContainsKey) {

        }

        if (-not $this.Hidden) {
            [Console]::Write("$($Sprite.Draw())")
            try {[Console]::CursorVisible = $false} catch {$PSCmdlet.WriteVerbose("$_")}
        }
    }
}