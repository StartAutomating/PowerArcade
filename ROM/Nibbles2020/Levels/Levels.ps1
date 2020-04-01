<#
.Synopsis

.Description

#>

Add-Sprite -X 0 -Y 0 -Width $game.Width -Height 1 -Type Wall # Top
Add-Sprite -X 0 -Y $game.Height -Width $game.Width -Height 1 -Type Wall # Bottom
Add-Sprite -X 0 -Y 1 -Width 1 -Height ($game.Height -1) -Type Wall # Left 
Add-Sprite -X $game.Width -Y 1 -Width 1 -Height ($game.Height - 1) -Type Wall #Right

$levelNumber = $game.CurrentLevelName -as [int]
if ($levelNumber -ge 10) {
    foreach ($blockNumber in 1..$levelNumber) {
        Add-Sprite -Type Wall -X $x -Y $y -Anywhere -Width (1, 3 | Get-Random) -Height (1,3 | Get-Random)
    }
    
    Add-Sprite -Type Number -Content 1 -AnyWhere -Name TargetNumber 

    Add-Sprite -Anywhere -Type Snake -Name Snake1 -Property @{Direction=1..4|Get-Random}        
}

$host.UI.RawUI.WindowTitle = @(
    $game.Name
    
    if ($game.CurrentLevelName -ne 'Menu') {
        "Level $($game.CurrentLevelName)"
        $game.Player1Score
        "$($game.Player1Lives)/$($game.Default.Player1Lives) Lives"
    }
) -join ' - '