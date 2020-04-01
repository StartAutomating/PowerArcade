$key = $args

if ($key.VirtualKeyCode -eq 32) { # Space, start the game
    Switch-Level -Name 1
}

$keyChar = [char]$key.VirtualKeyCode
if ($keyChar -match '\d') {
    
    if ($game.Levels["$keyChar"]) {
        Switch-Level $keyChar
    } else {
        Switch-Level -Name 10
    }
}

