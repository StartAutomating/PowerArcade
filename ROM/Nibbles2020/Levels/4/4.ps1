$wallHeight = ($game.Height * .6)
$verticalWall = @{Width=1;Height=$wallHeight;Type='Wall'}

_/\+ @verticalWall -X ($game.Width * .25) -Y 2
_/\+ @verticalWall -X ($game.Width * .75) -Y ($game.Height - $wallHeight) 

$wallWidth = ($game.Width * .6)
$horizontalWall = @{Height=1;Width=$wallWidth;Type='Wall'}

_/\+ @horizontalWall -X 2 -Y ($game.Height * .76)
_/\+ @horizontalWall -X ($game.Width - $wallWidth) -Y ($game.Height * .3)


Add-Sprite -X ($game.Width * .75) -Y ($game.Height * .1) -Type Snake -Name Snake1 -Property @{Direction=3}   

Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber