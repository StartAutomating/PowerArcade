$wallHeight = ($game.Height * .52)
$verticalWall = @{Width=1;Height=$wallHeight;Type='Wall'}

_/\+ @verticalWall -X ($game.Width * .2625) -Y ($game.Height * .26)
_/\+ @verticalWall -X ($game.Width * .7375) -Y ($game.Height * .26)

$wallWidth = ($game.Width * .425)
$horizontalWall = @{Height=1;Width=$wallWidth;Type='Wall'}

_/\+ @horizontalWall -X ($game.Width * .2875)  -Y ($game.Height * .22)
_/\+ @horizontalWall -X ($game.Width * .2875) -Y ($game.Height * .82)

Add-Sprite -X ($game.Width * .625) -Y ($game.Height * .5) -Type Snake -Name Snake1 -Property @{Direction=1}   

Add-Sprite -Type Number -Content 1 -Anywhere -Name TargetNumber