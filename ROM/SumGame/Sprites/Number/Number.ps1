$value = 1..9 | Get-Random # Pick a number between 1/9
$valueMultiplier = 1,1,-1 |  Get-Random # Give it a 2/3rds chance of being positive
$value *= $valueMultiplier 
$numberString = "$value"
$this.Value = $value # Keep track of the value in the sprite, for when we're hit
$this.Content = $numberString # update the display string
if ($this.Value -lt 0) { # If the number is negative
    $this.Color = '#ff0000' # make it red instead.
}