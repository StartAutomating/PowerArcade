@(
    [PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Message=$game.GameOverMessage;Y=$game.Height * .3;Border=$true}

    [PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Messages=@"
Level - $($game.LastLevelName)
Score - $($game.Player1Score)
"@, $($game.Controls -join [Environment]::NewLine);Y = $game.Height * .55;Border=$true
}
) |Out-String -Width 1kb | Write-Host -NoNewline
    



