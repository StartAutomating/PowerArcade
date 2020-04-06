function Restart-Level
{
    <#
    .Synopsis
        Restarts the current level
    .Description
        Used within a PowerArcade game to restart the current level.
    .Link
        Switch-Level
    .Link
        Suspend-Level
    .Link
        Resume-Level
    #>

    param(
    # If set, will not rerun the level initialize routines.
    [Alias('NoInit','DoNotInitialize')]
    [switch]
    $NoInitialize,

    # If set, will not clear the screen and sprite map.
    [Alias('DoNotClear')]
    [switch]
    $NoClear
    )

    process {
        if (-not $Global:Game) {
            Write-Error "Cannot restart a level without initializing the game."
            return
        }

        if (-not $NoClear) {
            Clear-Host
            if ($game.BackgroundColor) {
                # [Console]::Write(('' + [char]0x1b + '[1049l'))
                [Console]::Write(([PSCustomObject]@{
                    PSTypeName='PowerArcade.Box'
                    BackgroundColor = $game.BackgroundColor
                } | Out-String -Width 1kb).Trim())
                try {[Console]::CursorVisible = $false} catch {$PSCmdlet.WriteVerbose("$_")}
            }
            if ($game.CurrentLevel.Sprites.Clear) {
                $game.CurrentLevel.Sprites.Clear()
            }
            if ($game.CurrentLevel.SpritesByID.Clear) {
                $game.CurrentLevel.SpritesByID.Clear()
            }
            if ($game.CurrentLevel.SpatialMap.Clear) {
                $game.CurrentLevel.SpatialMap.Clear()
            }

            foreach ($X in 0..$game.CellWidth) {
                foreach ($Y in 0..$game.CellHeight) {
                    $game.CurrentLevel.SpatialMap["$X,$y"] = [Collections.Generic.List[PSObject]]::new()
                }
            }
        }

        if (-not $NoInitialize) {

            $Global:Game.CurrentLevel | Add-Member NoteProperty Initializing $true -Force
            if ($Global:Game.LevelBaseObject.Initialize.Invoke) {
                $Global:Game.LevelBaseObject.Initialize()
            }
            if ($Global:Game.CurrentLevel.Initialize.Invoke) {
                $Global:Game.CurrentLevel.Initialize()
            }
            if ($Global:Game.CurrentLevel.DynamicInitialize.Invoke) {
                $Global:Game.CurrentLevel.DynamicInitialize.Invoke()
            }

            $Global:Game.CurrentLevel.Initializing = $false
            $Global:Game.CurrentLevel.Draw()
        }
    }
}
