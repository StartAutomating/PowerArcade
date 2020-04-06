param($key) # Any OnKey_ script is passed the key press as a parameter.
# If you don't ignore either key up or key down, it will behave unexpectedly.
# If you want the key to respond to being held down, you'll want to ignore KeyUp
if (-not $key.KeyDown) { return } # (which we do here)

if ($Player) { # If there was a player on the screen
    $Player | # Move it RIGHT
        # (this works by piping the current player in, and using a [ScriptBlock] to alter the value for X)
        Move-Sprite -X { $_.X + 1 }  
}

