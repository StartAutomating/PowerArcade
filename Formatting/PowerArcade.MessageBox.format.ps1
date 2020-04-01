$messageData = $_
$Messages = 
    if ($_.Messages){
        $_.Messages
    } else {
        $_.Message
    }

$y = 
    if ($messageData.Y) {
        $messageData.Y
    } else {
        $GAME.Height * .33
    }

if ($messageData.Border -eq $true) {

}

$y--

$colorSplat = @{
    Color=
        $(
            if ($messageData.Color) {
                $messageData.Color
            } else {
                $game.TextColor
            }
        )
    BackgroundColor=
        $(
            if ($messageData.BackgroundColor) {
                $messageData.BackgroundColor
            } else {
                $game.BackgroundColor
            }
        )
}
@(foreach ($Message in $Messages) {
if (-not $Message) { continue } 
$MessageLines = @($Message -split '(?>\r\n|\n)')



$MaxLength = $MessageLines | 
    Measure-Object -Property Length -Maximum | 
    Select-Object -ExpandProperty Maximum

$TextLineStart = 
        if ($messageData.X) {
            $messageData.X
        } else {
            ($game.Width - $MaxLength) / 2
        }

    if ($messageData.Border -eq $true) {
        $Y++
        New-Sprite -Type Message -X $TextLineStart -Y $y -Content ('┌' + $('─' * $MaxLength) + '┐') @colorSplat
    }
    foreach ($MessageLine in $messageLines) {
        $y++
        if ($messageData.Border -eq $true) {
            
            New-Sprite -Type Message -X $TextLineStart -Y $y -Content $(
                
                '│' + "$MessageLine".PadRight($MaxLength) + '│'
                
            ) @colorSplat
        } else {
            New-Sprite -Type Message -X $TextLineStart -Y $y -Content $MessageLine @colorSplat
        }
    }
    if ($messageData.Border -eq $true) {
        $Y++
        New-Sprite -Type Message -X $TextLineStart -Y $y -Content ('└' + $('─' * $MaxLength) + '┘') @colorSplat
    }

}) | Out-String -Width 1kb