if ($this.Name -eq 'Snake1') {
    $game.Player1Lives--
    if (-not $game.Player1Lives) {
        $game.Over()
    } else {
        Restart-Level
    } 
}