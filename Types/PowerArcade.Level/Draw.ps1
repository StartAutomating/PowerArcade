[Console]::Write("$(@(
    foreach ($sprite in $this.Sprites) {
        [char]0x1b + '[25l' + ($sprite | Out-String -Width 1kb).Trim()
    }
) -join '')")
try {[Console]::CursorVisible = $false} catch {Write-Verbose "$_"}
