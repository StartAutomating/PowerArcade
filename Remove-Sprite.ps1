function Remove-Sprite
{
    <#
    .Synopsis
        Removes a Sprite
    .Description
        Removes a Sprite from the screen and the current level.
    .Example
        $byeByeSprite | Remove-Sprite
    .Link
        Add-Sprite
    .Link
        Find-Sprite
    .Link
        Move-Sprite
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Games Must Use the Host")]
    [OutputType([Nullable])]
    param(
    # The Sprite.
    [Parameter(Mandatory,ValueFromPipeline)]
    [PSTypeName('PowerArcade.Sprite')]
    [PSObject]
    $Sprite
    )

    process {
        if (-not $PSCmdlet.ShouldProcess("Remove $($sprite.Type) $($sprite.spriteID)")) {return }
        [Console]::Write("$($sprite.Clear())")

        if ($game.CurrentLevel -and $game.CurrentLevel.SpatialMap.ContainsKey) {

            foreach ($osh in $Sprite.SpatialHash) {
                if ($game.CurrentLevel.SpatialMap.ContainsKey($osh)) {
                    $toRemove =
                        @(for ($in =0 ; $in -lt $game.CurrentLevel.SpatialMap[$osh].Count; $in++) {
                            if ($game.CurrentLevel.SpatialMap[$osh][$in].SpriteID -eq $Sprite.SpriteID) {
                                $game.CurrentLevel.SpatialMap[$osh][$in]
                                break
                            }
                        })

                    foreach ($tr in $toRemove) {
                        $null = $game.CurrentLevel.SpatialMap[$osh].Remove($tr)
                    }
                    $null = $game.CurrentLevel.SpritesById.Remove($sprite.SpriteID)
                }
            }

            $null = $game.CurrentLevel.Sprites.Remove($sprite)
            $sprite.psobject.Properties.Remove('Level')
        }

        if ($sprite.Name) {
            $ExecutionContext.SessionState.PSVariable.Remove("global:$($Sprite.Name)")
        }

        $sprite | Add-Member NoteProperty Hidden $true -Force
    }
}
