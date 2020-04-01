function Initialize-Level
{
    <#
    .Synopsis
        Initializes Game Levels
    .Description
        Initializes Game Levels.

        Game Levels can be located in subdirectory named 'Leve' or 'Levels'.

        Any game level
    .Link
        Initialize-Level
    .Link
        Initialize-Sprite
    #>
    [CmdletBinding(DefaultParameterSetName='Game')]
    param(
    # The path to a specific level
    [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName,ParameterSetName='LevelPath')]
    [Alias('FullName')]
    [string]
    $LevelPath,

    # The path to a game.
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Game')]
    [Parameter(Position=1,ParameterSetName='LevelPath')]
    [PSTypename('PowerArcade.Game')]
    [PSObject]
    $Game
    )

    begin {
        $levelDirectories = [Collections.Generic.List[IO.DirectoryInfo]]::new()
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Game') {
            $levelRoot = $Game.Root |
                Get-ChildItem -Directory |
                Where-Object Name -In 'Level', 'Levels' |
                Select-Object -First 1

            if (-not $levelRoot) { return }
            $allLevels =[PSCustomObject]@{}
            foreach ($member in & $GetScriptMembers $levelRoot) {
                $allLevels.psobject.Members.Add($member, $true)
            }
            $game |
                Add-Member NoteProperty LevelBaseObject $allLevels -Force



            $gameLevels = $levelRoot |
                Get-ChildItem -Directory |
                Initialize-Level -Game $game

            $gameLevelsByName = [Ordered]@{}
            foreach ($gl in $gameLevels) {
                $gameLevelsByName[$gl.Name] = $gl
            }
            $game |
                Add-Member NoteProperty Levels $gameLevelsByName -Force

            return
        }

        $resolvedLevelPath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($LevelPath)
        if (-not $resolvedLevelPath) { return}
        $resolvedLevelItem = Get-Item -LiteralPath $resolvedLevelPath
        if (-not $resolvedLevelItem) { return }
        if ($resolvedLevelItem -is [IO.DirectoryInfo]) {
            $levelDirectories.Add($resolvedLevelItem)
        }
    }

    end {
        $c, $t, $id = 0, $levelDirectories.Count, [Random]::new().Next()
        foreach ($levelDir in $levelDirectories) {
            Write-Progress "Loading Levels" "$($levelDir.Name)" -Id $id -PercentComplete ($c * 100 / $t)
            $c++

            $levelObject = [PSCustomObject]@{
                PSTypeName='PowerArcade.Level';
                Name=$levelDir.Name;
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
                    $levelObject.SpatialMap["$X,$y"] = [Collections.Generic.List[PSObject]]::new()
                }
            }

            foreach ($member in & $GetScriptMembers $levelDir) {
                $levelObject.psobject.Members.Add($member, $true)
            }
            $levelObject
        }

        Write-Progress "Loading Levels" "Complete" -Id $id -Completed
    }
}
