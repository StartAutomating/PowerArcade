function Initialize-Sprite
{
    <#
    .Synopsis
        Initializes Sprites
    .Description
        Initializes Sprites for a Game.

        This will preload sprite behaviors and content for any sprite located beneath a Sprite(s) directory
    .Link
        Initialize-Game
    .Link
        Initialize-Level
    #>
    [CmdletBinding(DefaultParameterSetName='Game')]
    param(
    # The path to a specific sprite.
    [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName,ParameterSetName='SpritePath')]
    [Alias('FullName')]
    [string]
    $SpritePath,

    # The path to a game.
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Game')]
    [Parameter(Position=1,ParameterSetName='SpritePath')]
    [PSTypename('PowerArcade.Game')]
    [PSObject]
    $Game
    )

    begin {
        $SpriteDirectories = [Collections.Generic.List[IO.DirectoryInfo]]::new()
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Game') {
            $SpriteRoot = $Game.Root |
                Get-ChildItem -Directory |
                Where-Object Name -In 'Sprite', 'Sprites' |
                Select-Object -First 1

            if (-not $SpriteRoot) { return }
            $allSprites =[PSCustomObject]@{}
            foreach ($member in & $GetScriptMembers $SpriteRoot) {
                $allSprites.psobject.Members.Add($member, $true)
            }
            $game |
                Add-Member NoteProperty SpriteBaseObject $allSprites -Force



            $gameSprites = $SpriteRoot |
                Get-ChildItem -Directory |
                Initialize-Sprite -Game $game

            $gameSpritesByType = [Ordered]@{}
            foreach ($gs in $gameSprites) {
                $gameSpritesByType[$gs.Type] = $gs
            }
            $game |
                Add-Member NoteProperty SpriteTypes $gameSpritesByType -Force

            return
        }

        $resolvedSpritePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($SpritePath)
        if (-not $resolvedSpritePath) { return}
        $resolvedSpriteItem = Get-Item -LiteralPath $resolvedSpritePath
        if (-not $resolvedSpriteItem) { return }
        if ($resolvedSpriteItem -is [IO.DirectoryInfo]) {
            $SpriteDirectories.Add($resolvedSpriteItem)
        }
    }

    end {
        $c, $t, $id = 0, $SpriteDirectories.Count, [Random]::new().Next()
        foreach ($SpriteDir in $SpriteDirectories) {
            Write-Progress "Loading Sprites" "$($SpriteDir.Name)" -Id $id -PercentComplete ($c * 100 / $t)
            $c++

            $SpriteObject = [PSCustomObject]@{PSTypeName='PowerArcade.Sprite';Type=$SpriteDir.Name}
            foreach ($member in & $GetScriptMembers $SpriteDir) {
                $SpriteObject.psobject.Members.Add($member, $true)
            }
            $SpriteObject
        }

        Write-Progress "Loading Sprites" "Complete" -Id $id -Completed
    }
}
