param(
[Parameter(Mandatory)]
$X,

[Parameter(Mandatory)]
$Y
)

"$(
    [int][Math]::Floor($x / ($this.Width / $this.CellWidth))
),$(
    [int][Math]::Floor($y / ($this.Height / $this.CellHeight))
)"
