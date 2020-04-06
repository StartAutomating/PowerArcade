<#
.Synopsis
    The Game's OnTick Handler
.Description
    This script is called whenever the game clock ticks
#>

if ($game.CurrentLevel.StartTime) { # If the level is timed
    # Update the window title
    $host.UI.RawUI.WindowTitle = @("$($game.Name)"
    "{0} / {1}" -f $player.Score, $game.CurrentLevel.TargetScore
    "$([DateTime]::Now - $game.CurrentLevel.StartTime)".Substring(0,8)
    ) -join ' - '
}