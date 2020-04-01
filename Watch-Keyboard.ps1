function Watch-Keyboard
{
    <#
    .Synopsis
        Watches for Keyboard Input
    .Description
        Watches for Keyboard Input without blocking the script.

        When input arrives, it can be caught be any handler in -OnKey,
        and the results of that handler will be returned.

        If no input handler catches the key, it will be returned from Watch-Keyboard.

        If no keys are currently pressed, nothing will be returned.
    .Example
        # Watches the keys until you hit CTRL+C
        do { Watch-Keyboard | Select-Object -ExpandProperty Key } while ($true)
    .Link
        Watch-Game
    #>
    [OutputType([PSObject])]
    param(
    # A dictionary of key handlers.
    # The key should be the name of a key, and the value should be a script block.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]
    $OnKey,

    # The read key options.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('ReadKeyOptions')]
    [Management.Automation.Host.ReadKeyOptions]
    $ReadKeyOption = 'NoEcho,IncludeKeyDown,IncludeKeyUp'
    )

    process {
        :KeyLoop while ($Host.UI.RawUI.KeyAvailable) {
            #region Read the Keys
            $KeyRead = $Host.UI.RawUI.ReadKey($ReadKeyOption)
            $KeyReadAt = [DateTime]::Now
            if (-not $OnKey) {
                [PSCustomObject][Ordered]@{
                    PSTypeName='PowerArcade.Keypress'
                    Key = $KeyRead
                    TimeStamp = $KeyReadAt
                }
                continue
            }
            #endregion Read the Keys

            #region Deal with the Handlers
            :NextOnKey foreach ($kv in $(if ($OnKey) {$OnKey.GetEnumerator()})) {
                $key = "$($kv.Key)"
                if ($key.Contains('+'))
                {
                    # check for modifiers, and continue if not found
                    # if found, strip the modifiers from $key
                }
                $IsMatch =
                    ($key -eq 'Any') -or
                    ($key -eq 'All') -or
                    ($key -eq 'left' -and $KeyRead.virtualkeyCode -eq 37) -or
                    ($key -eq 'up' -and $KeyRead.virtualkeyCode -eq 38) -or
                    ($key -eq 'right' -and $KeyRead.virtualkeyCode -eq 39) -or
                    ($key -eq 'down' -and $KeyRead.virtualkeyCode -eq 40) -or
                    ($key -eq 'space' -and $keyRead.virtualKeyCode -eq 32) -or
                    (('esc', 'escape' -contains $key) -and $keyRead.virtualKeyCode -eq 27) -or
                    (('enter', 'return' -contains $key) -and $keyRead.VirtualKeyCode -eq 13) -or
                    (('back', 'backspace' -contains $key) -and $keyRead.VirtualKeyCode -eq 8) -or
                    ($KeyRead.character -eq $key)


                if ($IsMatch) {
                    if ($kv.Value -is [ScriptBlock]) {
                        . $kv.Value $keyRead
                    }
                    break KeyLoop
                }
            }
            #endregion Deal with the Handlers

            [PSCustomObject][Ordered]@{
                PSTypeName='PowerArcade.Keypress'
                Key = $KeyRead
                TimeStamp = $KeyReadAt
            }
        }
    }
}
