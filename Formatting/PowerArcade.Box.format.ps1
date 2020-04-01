@(
    $box = $_
    $boxWidth = 
        if ($_.Width) { $_.Width}
        else {$host.UI.RawUI.WindowSize.Width}
    $boxHeight =
        if ($_.Height) { $_.Height}
        else {$host.UI.RawUI.WindowSize.Height}
    $boxBackgroundColor = $box.BackgroundColor
    $boxColor = $box.Color

    $boxFill =
        if ($box.Fill) { $box.Fill }
        else { '█'; $boxColor = $boxBackgroundColor }

    



    $colorStart = 
        @(
            if ($boxColor) {
                $intColor = [int]($boxColor -replace '#', '0x')
                $r,$g,$b = 
                    [byte](($intColor -band 0xff0000) -shr 16),
                    [byte](($intColor -band 0x00ff00) -shr 8),
                    [byte]($intColor -band 0x0000ff)
                [char]0x1b+"[38;2;$r;$g;${b}m"
            }

            if ($box.BackgroundColor) {
                $intColor = [int]($box.BackgroundColor -replace '#', '0x')
                $r,$g,$b = 
                    [byte](($intColor -band 0xff0000) -shr 16),
                    [byte](($intColor -band 0x00ff00) -shr 8),
                    [byte]($intColor -band 0x0000ff)
                [char]0x1b+"[48;2;$r;$g;${b}m"
            }
        ) -join ''


    $colorEnd = 
        @(
            if ($boxColor) {
                [char]0x1b + '[39m'
            }

            if ($box.BackgroundColor) {
                [char]0x1b + '[49m'
            }
        ) -join ''
    $boxChar = [string]"$boxFill".Substring(0,1)

    if ($null -ne $box.X -and $null -ne $box.Y) {            
        @(for ($l =0 ;$l -lt $boxHeight; $l++) {
            $colorStart
            '' + [char]0x1b + "[$($box.Y + $l);$($box.X)H"
            $boxChar * $boxWidth
            $colorEnd
        }) -join ''
    } else {
        $colorStart
        @(
            for ($l = 0; $l -lt $boxHeight; $l++) {
                $boxChar * $boxWidth
            }
        ) -join [Environment]::NewLine
        $colorEnd
    }
    ''

    
) -join ''
