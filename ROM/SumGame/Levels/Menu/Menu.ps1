<#
.Synopsis
    Initializes the Menu
.Description
    Initializes the Menu Level.  
    This is used to display basic information about the game before playing.
.Notes
    This implementation of a menu shows up to 3 messages:
    * The $Game.Logo
    * The $Game.Instructions
    * The $Game.Controls

    Because of the generic way this can be written, you can often reuse this Menu implementation.
#>

# Show the game logo at the top 1/3rd
Show-Game -Message $game.Logo 

# Set a starting height for additional messages
$startHeight = $game.Height * .55 
if ($game.Instructions) { # If the game had instructions
    Show-Game -Message $game.Instructions -Y $startHeight -Border # show them with a border
    $startHeight += $game.Instructions.Count # and update the starting height.
    $startHeight += 4
}
if ($game.Controls) { # If the game had controls
    Show-Game -Message $game.Controls -Y $startHeight -Border # show them with a border.
}