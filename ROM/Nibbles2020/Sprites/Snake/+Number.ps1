param(
[Parameter(Mandatory)]
$Number
)


$intNumber = ([int]$number.Content)
$levelNumber = [int]$game.CurrentLevelName
$this.MaxLength+=($intNumber * 4)
$nextNumber = $intNumber + 1
if ($nextNumber -lt 10)  {
    $Number.Content = $nextNumber
    $this | Add-Member NoteProperty NextNumber $nextNumber -Force 
    $foundSpot = $false


    if ($levelNumber -ge 10) {        
        foreach ($n in 1..(($levelNumber - 10) + $nextNumber)) {
            Add-Sprite -Type Wall -X $x -Y $y -Anywhere -Width (1, 3 | Get-Random) -Height (1,3 | Get-Random)
        }        
    }
    do {
        $nx = Get-random -Minimum 2 -Maximum ($game.Width - 2)
        $ny = Get-random -Minimum 2 -Maximum ($game.Height - 2)
        if (-not (Find-Sprite -X $nx -Y $ny)) {
            $foundSpot = $true
        } 
    } while (-not $foundSpot)
    
    $Number | Move-Sprite -X $nx -Y $ny
} elseif ($game.CurrentLevelName -match '^\d+$') {
    $LevelNumber = [int]($Matches.0)
    $nextLevelNumber = $levelNumber + 1
    $this | Remove-Sprite
    Switch-Level -Name $nextLevelNumber    
}
if ($this.Name -eq 'Snake1') {
    $game.Player1Score += ($intNumber * $levelNumber)
    $host.UI.RawUI.WindowTitle = @(
        $game.Name
    
        if ($game.CurrentLevelName -ne 'Menu') {
            "Level $($game.CurrentLevelName)"
            $game.Player1Score
            "$($game.Player1Lives)/$($game.Default.Player1Lives) Lives"
        }
    ) -join ' - '
}
