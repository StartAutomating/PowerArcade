$x = $this.X -as [int]
$y = $this.Y -as [int]
@(if ($this.Width -and $this.Height) {
    for ($oy = 0; $oy -lt $this.Height; $oy++) {
        for ($ox = 0; $ox -lt $this.Width; $ox++) {
            "$($x + $ox),$($y + $oy)"
        }
    }
    
} elseif ($this.Content)  
{
    $cl = 
        if ($this.ContentLength) {
            $this.ContentLength
        } else {
            $this.Content.ToString().Length
        }
    for ($ox =0; $ox -lt $cl; $ox++) {
        "$($x + $ox),$y"
    }
} elseif ($x -ge 0 -and $y -ge 0) {
    "$x,$y"
}
)
