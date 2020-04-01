function Resume-Level
{
    <#
    .Synopsis
        Resumes a level
    .Description
        Resumes a level suspended with Suspend-Level
    .Example
        Resume-Level
    .Link
        Suspend-Level
    #>
    param()
    if (-not $Global:Game) { return }


    if (-not $Global:Game.SuspendedLevel) { return }
    if (-not $Global:Game.SuspendedLevelName) { return }
    $Global:Game.CurrentLevel  = $Global:Game.SuspendedLevel
    $Global:Game.CurrentLevelName =  $Global:Game.SuspendedLevelName
    Clear-Host
    if ($game.BackgroundColor) {
        # [Console]::Write(('' + [char]0x1b + '[1049l'))
        ([PSCustomObject]@{
            PSTypeName='PSArcade.Box'
            BackgroundColor = $game.BackgroundColor
        } | Out-String -Width 1kb).Trim() | Write-Host -NoNewline
    }
    if ($Global:Game.CurrentLevel.Draw) {
        $Global:Game.CurrentLevel.Draw()
    }
}
