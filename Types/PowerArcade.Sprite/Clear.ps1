@(if ($this.X -ge 0 -and $this.Y -ge 0) {
    '' + [char]0x1b + "[$($this.Y);$($this.X)H"
}
if ($this.Shapes) {
    @(foreach ($shape in $this.Shapes) {
        $newShape = [PSCustomObject]::new()
        foreach ($member in $shape.Members) {
            $newShape.psobject.members.add($member, $true)
        }
        $newShape.psobject.members.add([PSNoteProperty]::new('Color', $game.BackgroundColor), $true)
        $newShape.psobject.members.add([PSNoteProperty]::new('BackgroundColor', $game.BackgroundColor), $true)
        $newShape.psobject.members.add([PSNoteProperty]::new('Fill', ''), $true)
        $newShape
    }) | Out-String -Width 1kb
} elseif ($this.Content) {
        if ($this.BackgroundColor -or $game.BackgroundColor) {
        $bgColor = if ($this.BackgroundColor) { } elseif ($game.BackgroundColor) { $game.BackgroundColor }
        $intColor = [int]($bgColor -replace '#', '0x')
        $r,$g,$b = 
            [byte](($intColor -band 0xff0000) -shr 16),
            [byte](($intColor -band 0x00ff00) -shr 8),
            [byte]($intColor -band 0x0000ff)
                    
        '' + [char]0x1b+"[48;2;$r;$g;${b}m"
    
    }
    #$intColor = [int]($game.BackgroundColor -replace '#', '0x')
    if ($this.ContentLength) {
        ' ' * $this.ContentLength
    } else {
        ' ' * "$($this.Content)".Length
    }
                
}
'' + [char]0x1b + '[25l'
) -join ''
