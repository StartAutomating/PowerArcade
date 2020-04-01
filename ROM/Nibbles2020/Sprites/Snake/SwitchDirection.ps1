<#
.Synopsis
    Changes the snake direction
.Description
    Changes the snake direction
#>
param(
[Parameter(Mandatory)]
[ValidateSet('Up','Down','Left','Right')]
[string]
$Direction
)

if ($Direction -eq 'UP' -and $this.Direction -ne 2) {
    $this.Direction = 1 
}
elseif ($Direction -eq 'DOWN' -and $this.Direction -ne 1) {
    $this.Direction = 2
}
elseif ($Direction -eq 'LEFT' -and $this.Direction -ne 4) {
    $this.Direction = 3
}
elseif ($Direction -eq 'RIGHT' -and $this.Direction -ne 3) {
    $this.Direction = 4
}