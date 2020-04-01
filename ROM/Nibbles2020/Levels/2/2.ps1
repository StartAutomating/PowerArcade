Add-Sprite -X ($game.Width * .25) -Y ($game.Height * .5) -Width ($game.Width * .5) -Height 1 -Type Wall # Middle Wall
Add-Sprite -X ($game.Width * .75) -Y ($game.Height * .1) -Type Snake -Name Snake1 -Property @{Direction=3}   
Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber