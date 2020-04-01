Add-Sprite -Type Snake -X ($game.Width * (5/8)) -Y ($game.Height /2) -Property @{
    Direction = 4
} -Name Snake1

Add-Sprite -Type Number -Content 1 -Name TargetNumber -Anywhere
