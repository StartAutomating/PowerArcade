param(
[int]
$X = $this.X,

[int]
$Y = $this.Y
)


if ($this.Width -and $this.Height) {
    for ($oy = 0; $oy -lt $this.Height; $oy++) {
        for ($ox = 0; $ox -lt $this.Width; $ox++) {

            [PSCustomObject]@{
                X = $x + $ox
                Y = $y + $oy
                SpatialHash = 
                    $(if ($game.GetSpatialHash) { 
                        $game.GetSpatialHash($x + $ox,$y + $oy)
                    })
                PSTypeName='PowerArcade.Point'
            }
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
        [PSCustomObject]@{
            X = $x + $ox
            Y = $y
            SpatialHash = 
                $(if ($game.GetSpatialHash) {
                    $game.GetSpatialHash($x + $ox,$y)
                })
            PSTypeName='PowerArcade.Point'
        }
    }
} elseif ($x -ge 0 -and $y -ge 0) {
    [PSCustomObject]@{
        X = $x
        Y = $y
        SpatialHash =
            $(if ($game.GetSpatialHash) {
                $game.GetSpatialHash($x,$y)
            })
        PSTypeName='PowerArcade.Point'
    }
}


