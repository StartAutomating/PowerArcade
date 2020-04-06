<#
.Synopsis
    Collision handler for Currency
.Description
    This script is run whenever the Player sprite collides with the Currency Sprite

    The Currency Sprite is passed as a parameter
#>
param($currency)

$player.Score += $currency.Value

$currency | Remove-Sprite

# Add two more currency symbols
Add-Sprite -Type Number -Anywhere
Add-Sprite -Type Number -Anywhere

if ($player.Score -eq $game.CurrentLevel.TargetScore) {
    Restart-Level
} else {

    $Host.UI.RawUI.WindowTitle = [String]::Format(
        "$($game.Name) - {0} / {1} - $("$([DateTime]::Now - $game.CurrentLevel.StartTime)".Substring(0,8))", 
        $player.Score, 
        $game.CurrentLevel.TargetScore)
}
