$UpperWall = @{Width=1;Y=1;Height=$game.Height * .72;Type='Wall'}
$LowerWall = @{Width=1;Y=($game.Height * .28);Height=$game.Height * .72;Type='Wall'}
$Gap = $game.Width / 8
for ($x =0; $x -lt $game.Width; $x+=$gap) {
    if (($x % ($gap * 2))) {
        _/\+ @UpperWall -X $x
    } else {
        _/\+ @LowerWall -X $x    
    }
}

Add-Sprite -X ($game.Width * .8125) -Y ($game.Height * .14) -Type Snake -Name Snake1 -Property @{Direction=2}
Add-Sprite -Type Number -Content 1 -Anywhere -Name TargetNumber