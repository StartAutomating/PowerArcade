@(
    '' + [char]0x1b + '[25l'
    if ($this.X -ge 0 -and $this.Y -ge 0) {
        '' + [char]0x1b + "[$($this.Y);$($this.X)H"
    }
    if ($this.Color) {
        $intColor = [int]($this.Color -replace '#', '0x')
        $r,$g,$b = 
            [byte](($intColor -band 0xff0000) -shr 16),
            [byte](($intColor -band 0x00ff00) -shr 8),
            [byte]($intColor -band 0x0000ff)
                    
        '' + [char]0x1b+"[38;2;$r;$g;${b}m"
    }
    if ($this.BackgroundColor -or $game.BackgroundColor) {
        $bgColor = if ($this.BackgroundColor) { $this.BackgroundColor } elseif ($game.BackgroundColor) { $game.BackgroundColor }
        $intColor = [int]($bgColor -replace '#', '0x')
        $r,$g,$b = 
            [byte](($intColor -band 0xff0000) -shr 16),
            [byte](($intColor -band 0x00ff00) -shr 8),
            [byte]($intColor -band 0x0000ff)
                    
        '' + [char]0x1b+"[48;2;$r;$g;${b}m"
    
    }
    if ($this.Shapes) {
        ($this.Shapes | Out-String -Width 1kb).Trim()
    } elseif ($this.Content) {
        "$($this.Content)"
    }
    if ($this.Color) {
        [char]0x1b +"[39m"
    }
    if ($this.BackgroundColor -or $game.BackgroundColor) {
        [char]0x1b +"[49m"
    }
    '' + [char]0x1b + '[25h'
) -join ''
