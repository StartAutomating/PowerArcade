@(foreach ($xy in $this.MeasureBounds()) {
    $x, $y = "$xy".Split(',')
    "$(
        [int][Math]::Floor($x / ($game.Width / $game.CellWidth))
    ),$(
        [int][Math]::Floor($y / ($game.Height / $game.CellHeight))
    )"
}) | Select-Object -Unique

