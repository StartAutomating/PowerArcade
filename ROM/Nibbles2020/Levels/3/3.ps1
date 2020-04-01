foreach ($x in ($game.Width * .25), ($game.Width * .75)) {
    _/\+ -Type Wall -X $x -Y ($game.Height * .25) -Width 1 -Height ($game.Height * .5)
}
Add-Sprite -X ($game.Width * .75) -Y ($game.Height * .1) -Type Snake -Name Snake1 -Property @{Direction=3}
Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber