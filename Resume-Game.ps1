function Resume-Game
{
    <#
    .Synopsis
        Resumes a Game
    .Description
        If a Game has been stopped but is still in memory, resumes the game from its current state 
    .Example
        Resume-Game
    .Link
        Watch-Game
    #>
    param()

    if (-not $game) { # If there is no game,
        Write-Error "No Game to Resume" # error 
        return # and return.
    }
    Show-Game -GameState    # We show the current game state
    $game.IsRunning = $true # then mark the game as running
    $game | Watch-Game      # then watch the game.
}