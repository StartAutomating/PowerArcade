<#
.Synopsis
    Initializes the Main Level
.Description
    Initializes the Main Level (the actual game)
.Notes
    In this Game, A Player (represented by a +) will eat numbers until a total is reached.

    Numbers can be positive or negative, and can have a value between 1-9.

    When any number is eaten, two new numbers will be created.

    When the total is reached exactly, the level will restart.

#>

# First, create the player sprite, and put it anywhere.
Add-Sprite -Type Player -Anywhere -Name Player  # By using -Name Player, $Player will be available elsewhere in the game.

foreach ($n in 1..5) { # Next, add 5 numbers, anywhere
    Add-Sprite -Type Number -Anywhere
}

# Then set, the level's target score
$this.TargetScore = Get-Random -Minimum 10 -Maximum 100
$this.StartTime = [DateTime]::Now

# And update the window title.
$Host.UI.RawUI.WindowTitle = 
    @("$($game.Name)"
    "{0} / {1}" -f $player.Score, $this.TargetScore
    ) -join ' - '
