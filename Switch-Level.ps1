function Switch-Level
{
    <#
    .Synopsis
        Switches the game level
    .Description
        Switches to a different level of the game.

        If the level does not exist, a message will be written to -Verbose, and the game will otherwise continue to run.
        This enables virtual levels of increasing difficulty.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Games Must Use the Host")]
    [OutputType([Nullable])]
    param(
    # The name of the level
    [Parameter(Mandatory,Position=0)]
    [Alias('Level')]
    [string]
    $Name,

    # A script to run after switching the level.  This can be used to provide dynamic level setup
    [ScriptBlock]
    $Then,

    # If set, will not run the Level's initialize routine
    [Alias('NoInit','DoNotInitialize')]
    [switch]
    $NoInitialize,

    # If set, will not clear the screen, clear the spritemap, and clear the sprite list
    [Alias('DoNotClear')]
    [switch]
    $NoClear,

    # If set, will clear the screen and redraw the current level.
    [switch]
    $Redraw
    )

    process {
        if (-not $Global:Game) {
            Write-Error "Cannot switch a level without initializing the game."
            return
        }
        if ($Global:Game.CurrentLevelName -eq $Name) { return }
        if (-not $Global:Game.Levels[$Name]) {
            #region Initialize Dynamic Level
            Write-Verbose "Level name $name not found in $($game.Name)"
            $Global:Game.CurrentLevel = [PSCustomObject]@{
                PSTypeName='PowerArcade.Level';
                Name=$Name;
                Sprites=[Collections.Generic.List[PSObject]]::new()
                SpatialMap =
                    [Collections.Generic.Dictionary[
                        string,
                        [Collections.Generic.List[PSObject]]
                    ]]::new([StringComparer]::OrdinalIgnoreCase)
                SpritesByID =
                    [Collections.Generic.Dictionary[
                        string,
                        [PSObject]
                    ]]::new([StringComparer]::OrdinalIgnoreCase)
                SpriteMap=[Collections.Generic.Dictionary[string,[Collections.Queue]]]::new([StringComparer]::OrdinalIgnoreCase)
            }

            foreach ($X in 0..$game.CellWidth) {
                foreach ($Y in 0..$game.CellHeight) {
                    $Game.CurrentLevel.SpatialMap["$X,$y"] = [Collections.Generic.List[PSObject]]::new()
                }
            }

            #endregion Initialize Dynamic Level
        } else {
            $Global:Game.CurrentLevel = $Global:Game.Levels[$Name]
        }
        $Global:Game.CurrentLevelName = $Name

        $OnKey = @{}
        foreach ($method in @($Global:Game.psobject.Methods; $Global:Game.CurrentLevel.psobject.Methods)) {
            if ($method.Name -like 'OnKey_*') {
                $onKey[$method.Name.Substring(6)] = $method.Script
            }
        }
        $Global:Game.PSObject.Members.Add([PSNoteProperty]::new('KeyHandlers', $OnKey))


        if ($Redraw) {
            Clear-Host
            if ($game.BackgroundColor) {
                # [Console]::Write(('' + [char]0x1b + '[1049l'))
                ([PSCustomObject]@{
                    PSTypeName='PowerArcade.Box'
                    BackgroundColor = $game.BackgroundColor
                } | Out-String -Width 1kb).Trim() | Write-Host -NoNewline
            }

            $Game.CurrentLevel.Draw()

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
            }            
            try {[Console]::CursorVisible = $false} catch {$PSCmdlet.WriteVerbose("$_")}
            if ($game.CurrentLevel.Sprites.Clear) {
                $game.CurrentLevel.Sprites.Clear()
            }
            if ($game.CurrentLevel.SpriteMap.Clear) {
                $game.CurrentLevel.SpriteMap.Clear()
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
            if ($then) {
                $Global:Game.CurrentLevel | Add-Member NoteProperty DynamicInitialize $then -Force
            }
            if ($Global:Game.CurrentLevel.DynamicInitialize.Invoke) {
                $Global:Game.CurrentLevel.DynamicInitialize.Invoke()
            }

            $Global:Game.CurrentLevel.Initializing = $false
        }

        $Global:Game.CurrentLevel.Draw()
    }
}
