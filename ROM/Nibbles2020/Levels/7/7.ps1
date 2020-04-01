$wallHeight = ($game.Height * .52)
$verticalWall = @{Width=1;Height=1;X=$game.Width*.5;Type='Wall'}
for ($y =4; $y -lt ($game.Height - 4); $y+= 2) {
    _/\+ @verticalWall -Y $y
}

Add-Sprite -X ($game.Width * .8125) -Y ($game.Height * .14) -Type Snake -Name Snake1 -Property @{Direction=2}   

Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber