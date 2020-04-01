param([Parameter(Mandatory)][int]$X,[Parameter(Mandatory)][int]$Y)
$this | Move-Sprite -X $X -Y $Y
return