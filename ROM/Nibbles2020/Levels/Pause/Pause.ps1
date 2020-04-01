([PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Message=@'
GAME PAUSED

Press P to resume
'@;Border=$true}) |Out-String -Width 1kb | Write-Host -NoNewline
