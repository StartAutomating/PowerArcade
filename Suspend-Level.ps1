function Suspend-Level
{
    <#
    .Synopsis
        Suspends a level
    .Description
        Suspends a level data in $game.SuspendedLevel and $Game.SuspendedLevelName.

        This can be resumed with Resume-Level
    .Example
        Suspend-Level
    .Link
        Resume-Level
    #>
    [OutputType([Nullable])]
    param()

    #region Hold Up
    if (-not $Global:Game) { return }

    $game | Add-Member NoteProperty SuspendedLevel $game.CurrentLevel -Force
    $game | Add-Member NoteProperty SuspendedLevelName $game.CurrentLevelName -Force
    #endregion Hold Up
}
