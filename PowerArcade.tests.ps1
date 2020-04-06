$TestGame = @{
    Game = @{
        "Game.psd1" = {@{BackgroundColor = '#0000ff'}}
        'OnKey_Left.ps1' = {
$dot | Move-Sprite -X ($dot.X - 1) -Y ($dot.Y)
}
        'OnKey_Right.ps1' = {
$dot | Move-Sprite -X ($dot.X + 1) -Y ($dot.Y)
}
        'OnKey_Up.ps1' = {
$dot | Move-Sprite -X ($dot.X) -Y ($dot.Y - 1)
}
        'OnKey_Down.ps1' = {
$dot | Move-Sprite -X ($dot.X) -Y ($dot.Y - 1)
}
        'Game.ps1' = {
$global:GameInitialized = $true
}
    }
    Levels = @{
        1 = @{
            '1.ps1' = {
                $Global:FirstLevelInitializedAt = [DateTime]::Now
                Add-Sprite -X ($game.Width / 2) -Y ($game.Height / 2) -Name Dot -Type Dot

                Add-Sprite -X ($game.Width * .45) -Y ($game.Height / 2) -Height 3 -Width 1 -Name LeftObstacle -Type Wall

                Add-Sprite -X ($game.Width * .55) -Y ($game.Height / 2) -Name RightObstacle -Type Wall

            }
        }
        'Levels.ps1' = {
            $Global:AllLevelsInitializedAt = [DateTime]::Now
        }
    }
    Sprites = @{
        Dot = @{
            'Dot.psd1' = {@{Content = 'O'}}
        }
        Wall = @{
            'Wall.psd1' = {@{Content = '█'}}
        }
    }
}


$popDir = {
    param(
        [Parameter(Mandatory)][string]$root,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$key,
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $value
    )

    process {
        $dest = Join-Path $root $key
        if ($value -is [Collections.IDictionary]) {
            if (-not (Test-Path $dest)) {
                $newDir = New-Item -ItemType Directory -Path $dest
            }
            $value.GetEnumerator() | & $MyInvocation.MyCommand.ScriptBlock -Root $dest
        } else {
            [IO.File]::WriteAllText($dest, "$value")
        }
    }
}

$tempDir =
    if ($PSVersionTable.Platform -eq 'Windows' -or -not $PSVersionTable.Platform) {
        Join-Path $env:TEMP "TempGame$(Get-Random)"
    } else {
        Join-Path '/tmp' "TempGame$(Get-Random)"
    }



$newDir = New-Item -ItemType Directory -Path $tempDir -Force
$psd1Path = Join-Path $newDir "$($newDir.Name).psd1"
"@{ModuleVersion='0.1'}" | Set-Content $psd1Path
    $TestGame.GetEnumerator() | & $popDir -Root $newDir

$global:TheTestGame = $null
$global:GameInitialized = $false
$Global:AllLevelsInitializedAt = $null
$Global:FirstLevelInitializedAt = $null



describe PowerArcade {
    it 'Is a Game Engine Written in PowerShell' {
        Get-Module PowerArcade |
            ForEach-Object { $_.ExportedCommands.Values } |
            Where-Object { $_.Noun -eq 'Game' } |
            should belike '*-Game*'
    }

    it "Lets you define games with a trio of directories: 'Game', 'Level(s)', and 'Sprites'" {
        $directoryNames = $newdir |
            Get-ChildItem -Directory |
            Select-Object -ExpandProperty Name

        if ($directoryNames -notcontains 'Game') {
            throw "'Game' directory not found beneath '$newDir'"
        }
        if (-not ($directoryNames -match '^Level[s]?')) {
            throw "'Levels' directory not found beneath '$newdir'"
        }
        if (-not ($directoryNames -match '^Sprite[s]?')) {
            throw "'Sprites' directory not found beneath '$newDir'"
        }
    }

    context Game {

        it 'Can Initialize-Game' {
            $global:TheTestGame  = Initialize-Game -GamePath $newDir -NoClear

            $global:TheTestGame.pstypenames | should be 'PowerArcade.Game'
        }

        it 'Initializing a Game will call the Game.ps1 script in the Game directory' {
            $global:GameInitialized | should be $true
        }
    }

    context Levels {
        it 'Will default to the first level (alphabetically)' {
            $global:TheTestGame.currentlevelname | should be "1"
        }
        it 'Will run the Initialize method for all levels' {
            $Global:AllLevelsInitializedAt | should -BeLessOrEqual $Global:FirstLevelInitializedAt
        }
        it 'Will run the Initialize method for the currently selected level' {
            $Global:FirstLevelInitializedAt | should -BeGreaterOrEqual $Global:AllLevelsInitializedAt
        }
    }

    it 'Can Watch for keyboard input' {
        $noKeys = Watch-Keyboard
        $noKeys | should be $null
    }
}

describe Games {
    it 'Got Game' {
        $games = Get-Game
        $games | 
            Select-Object -ExpandProperty PSTypeNames | 
            Select-Object -First 1 | 
            should be PowerArcade.GameInfo
    }
    it 'Can find games' {
        $foundGames  = Find-Game
        $foundGames | Select-Object -ExpandProperty PSTypeNames
    }
}

describe Sprites {
    context Add-Sprite {
        it 'Can Add-Sprite to add content to the screen' {
            Add-Sprite -X ($dot.X + 3) -Y ($dot.Y + 3) -Content '!'
        }
        it 'Will not corrupt the spatial map to add a sprite right next to another one' {
            Add-Sprite -X ($LeftObstacle.X - 1) -Y ($dot.Y) -Type Dot
            $lo = $LeftObstacle
            $global:foundSomething = $LeftObstacle | Find-Sprite # # | should be $LeftObstacle
            if (-not $foundSomething) { throw "Found nothing" }
        }
        it 'Can add a sprite anywhere' {
            $addedSprite = Add-Sprite -Anywhere -Type Dot -Color "#ff0000" -PassThru
            $addedOtherSprite = Add-Sprite -Type Wall -Anywhere -Width 3 -Height 3 -PassThru
        }
    }

    context Find-Sprite {
        it 'Can Find-Sprite to see what is there' {
            Find-Sprite -X $dot.X -Y $dot.Y | should be $Global:Dot
        }
        it 'Can Find-Sprite within a -Radius' {
            $dot | Move-Sprite -X ($game.Width / 2) -Y ($game.Height / 2)
            Find-Sprite -X ($dot.x + 1) -Y ($DOT.y + 1) -Radius 2 |
                Measure-Object |
                Select-Object -ExpandProperty Count |
                should be 1
        }
    }

    context Move-Sprite {
        it 'Can Move a Sprite' {
            $ox = $dot.x
            $dot | Move-Sprite -X ($dot.X - 1) -Y $dot.Y
            $dot.X | should be ($ox - 1)
        }
        it 'Can Move next to a Sprite, and still find it (and the adjacent sprite)' {
            $dot | Move-Sprite -X ($RightObstacle.X - 1) -Y ($dot.Y)
            $RightObstacle | Find-Sprite | should be $RightObstacle
            $dot | Find-Sprite | should be $dot
        }
        it 'Can Move next to a Sprite with -NoClear, and still find it (and the adjacent sprite)' {
            $dot | Move-Sprite -X ($RightObstacle.X + 1) -Y ($RightObstacle.Y + 1) -NoClear
            $RightObstacle | Find-Sprite | should be $RightObstacle
            $dot | Find-Sprite | should be $dot
        }
    }

    context Remove-Sprite {
        it 'Can Remove-Sprite when we are done with it' {
            $leftX, $leftY = $LeftObstacle.X, $LeftObstacle.Y
            $spatialHash = $LeftObstacle.SpatialHash
            $spriteId = $LeftObstacle.SpriteID
            $lo = $LeftObstacle
            $LeftObstacle | Remove-Sprite
            $LeftObstacle | should be $null
            Find-Sprite -X $leftX -Y $leftY | should be $null
            $game.CurrentLevel.SpatialMap[$spatialHash] |
                Where-Object { $_.SpriteID -eq $spriteId } |
                should be $null
            $game.CurrentLevel.SpritesByID.ContainsKey($spriteId) | should be $false
            if ($game.CurrentLevel.Sprites -contains $lo) {
                throw "Sprite still in CurrentLevel.Sprites"
            }
        }

        it 'Will not corrupt up the spatial map during a Remove' {
            $dot | Move-Sprite -X ($RightObstacle.X - 1) -Y ($RightObstacle.Y)
            $RightObstacle | Remove-Sprite
            $dot | Find-Sprite | should be $dot

        }
    }
}

Remove-Item $newdir -Recurse -Force


