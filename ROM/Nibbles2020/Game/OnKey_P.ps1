param(
$key
)

if (-not $key.KeyDown) { return }
if ($game.CurrentLevelName -eq 'Pause') {
    Resume-Level     
    # Switch-Level $game.SuspendedLevelName -Redraw 
} else {
    Suspend-Level

    Switch-Level -Name 'Pause'
}
