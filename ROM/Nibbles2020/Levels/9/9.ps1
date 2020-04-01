$MiniWall = @{Width=1;Height=1;Type='Wall'}

$startHeight = [int]($game.Height * .15)
$endHeight = [int]($game.Height * .85)

for ($y = $startHeight; $y -lt $endHeight; $y++) {
    _/\+ @MiniWall -Y $y -X $Y
    _/\+ @MiniWall -Y $y -X ($Y + ($Game.Width * .45))
}

Add-Sprite -X ($game.Width * .8125) -Y ($game.Height * .14) -Type Snake -Name Snake1 -Property @{Direction=2}   

Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber