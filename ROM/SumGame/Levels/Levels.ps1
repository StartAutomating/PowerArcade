<#
.Synopsis
    All Levels Initialization Script
.Description
    This Script is called When Any Levels Initialize.
#>


# In this game, we want to draw four walls.


# The Top Wall
Add-Sprite -X 0 -Y 0 -Width $game.Width -Height 1 -Type Wall
# The Bottom Wall
Add-Sprite -X 0 -Y $game.Height -Width $game.Width -Height 1 -Type Wall
# The Left Wall
Add-Sprite -X 0 -Y 1 -Width 1 -Height ($game.Height -1) -Type Wall
# The Right Wall
Add-Sprite -X $game.Width -Y 1 -Width 1 -Height ($game.Height - 1) -Type Wall
