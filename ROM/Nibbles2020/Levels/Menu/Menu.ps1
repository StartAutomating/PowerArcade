
@([PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Message=$game.Logo -join [Environment]::NewLine;}


$startHeight = $game.Height * .55
[PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Message=$game.Instructions -join [Environment]::NewLine;Y=$startHeight;Border=$true}
$startHeight += $game.Instructions.Count
$startHeight += 4
[PSCustomObject]@{PSTypeName='PowerArcade.MessageBox';Message=$game.Controls -join [Environment]::NewLine;Y=$startHeight;Border=$true}
) | Out-String -Width 1kb | Write-Host -NoNewline

return

