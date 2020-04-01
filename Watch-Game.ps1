function Watch-Game
{
    <#
    .Synopsis
        Watches the Game Loop
    .Description
        While the game is running, this function will:

        * Watch for keyboard input
        * Call any key handlers
        * Call any OnTick events found on the Game, CurrentLevel, or loaded sprites
        * Sleep until the next expected $game.Clock event
    .Notes
        Unless you are building a game, you won't run this command directly.
        This command will be run within Initialize-Game, which in turn is called
    .Example
        Initialize-Game -GamePath .\ROM\Nibbles2020 | Add-Member NoteProperty IsRunning $true -Force -PassThru | Watch-Game
    .Link
        Start-Game
    .Link
        Initialize-Game
    #>
    param(
    # The Game Object
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='Game')]
    [Parameter(Position=1,ParameterSetName='LevelPath')]
    [PSObject]
    $Game
    )

    begin {
        $NotifyTick = {
            if ($game.OnTick.Invoke) {
                $game.OnTick()
            }

            if ($game.CurrentLevel.OnTick.Invoke) {
                $game.CurrentLevel.OnTick()
            }

            foreach ($gameSprite in @($game.CurrentLevel.Sprites)) {
                if ($gameSprite.OnTick.Invoke) {
                    $gameSprite.OnTick()
                }
            }
        }

    }

    process {
        $lastTick = $null
        $game | Add-Member NoteProperty LoopCounter 0 -Force

        :GameLoop while ($game.IsRunning) {
            $game.LoopCounter++
            & $NotifyTick
            $keyInput = @(
                $keySplat = @{}
                if ($Game.KeyHandlers) {
                    $keySplat['OnKey'] = $Game.KeyHandlers
                }
                . Watch-Keyboard @keySplat
            )
            if ($keyInput -and $keyInput.Key.VirtualKeyCode -ne 10 -and $keyInput.Key.VirtualKeyCode -ne 13) {
                $null = $null
            }
            $gameClock = $game.Clock -as [Timespan]
            if (-not $gameClock) { $gameClock = [Timespan]'00:00:00.02' }
            do {
                [Threading.Thread]::Sleep(1)
                # Start-Sleep -Milliseconds 1
            } while ($lastTick -and ([DateTime]::Now -lt $nextTick))

            $lastTick = [DateTime]::Now
            $nextTick = $lastTick + $gameClock
        }
    }
}