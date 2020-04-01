$xy = 
@(switch ($this.Direction) {
    1 {
        $this.X, ($this.Y - 1)
    }
    2 {
        $this.X, ($this.Y + 1)
    }
    3 {
        ($this.X -1), $this.Y
    }
    4 {
        ($this.X+ 1), $this.Y
    }
})
$oldX, $oldy = $this.X, $this.Y
$this | Move-Sprite @xy -NoClear
$intColor = [int]($this.Color)
$r,$g,$b = 
    [byte](($intColor -band 0xff0000) -shr 16),
    [byte](($intColor -band 0x00ff00) -shr 8),
    [byte]($intColor -band 0x0000ff)
$r=[byte]($r* .75)
$g=[byte]($g *.75)
$b=[byte]($b * .75)


$MoreTail = Add-Sprite -Type Tail -Content $this.Content -X $oldX -Y $oldy -Property @{
    TimeStamp = [DateTime]::Now
} -Color ("#{0:x2}{1:x2}{2:x2}" -f $r,$g,$b) -PassThru

$snakeTail = @($MoreTail) + $snake1.Tail
$snakeTail = @($snakeTail | Sort-Object TimeStamp -Descending)

$StillTail = $snakeTail[0..($snake1.MaxLength)]
$TailToRemove =$snakeTail[($snake1.MaxLength + 1)..($snakeTail.Length)]

if ($TailToRemove) {
    @($TailToRemove -ne $null) | Remove-Sprite
}


$snake1 | Add-Member NoteProperty Tail $StillTail -Force

