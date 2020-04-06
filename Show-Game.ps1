function Show-Game
{
    <#
    .Synopsis
        Shows the game, or shows messages in the game.
    .Description
        By default, Shows the game (redrawing the current level and state).

        When -Message is provided, shows in-game messages.
    .Example
        Show-Game
    .Link
        Start-Game
    #>
    [CmdletBinding(DefaultParameterSetName='GameState')]
    param(
    # The Message to display
    [Parameter(Position=0,ParameterSetName='Message',ValueFromPipelineByPropertyName)]
    [string[]]
    $Message,

    # The X-coordinate of the message. If not provided, this will default to center the message on the game width.
    [Parameter(ParameterSetName='Message',ValueFromPipelineByPropertyName)]
    [int]
    $X,

    # The Y-coordinate of the message. If not provided, this will default to 1/3rd of the game height.
    [Parameter(ParameterSetName='Message',ValueFromPipelineByPropertyName)]
    [int]
    $y,


    # If provided, the message will have a border.
    [Parameter(ParameterSetName='Message',ValueFromPipelineByPropertyName)]
    [switch]
    $Border,

    # While the command shows game state by default, you can pass -GameState for clarity in code.
    [Parameter(ParameterSetName='GameState',ValueFromPipelineByPropertyName)]
    [switch]
    $GameState
    )

    begin {
        $allMessages = [Collections.Generic.List[PSObject]]::new()
    }

    process {
        #region Showing a Message
        if ($PSCmdlet.ParameterSetName -eq 'Message')
        {
            # If we're showing a message,
            $PSBoundParameters.Message = # Join all message lines into a single string
                $PSBoundParameters.Message -split '(?>\r\n|\n)' -join [Environment]::NewLine
            $allMessages.Add([PSCustomObject]( # then create a MessageBox using the bound parameters
                [Ordered]@{PSTypeName='PowerArcade.MessageBox'} + $PSBoundParameters
            )) # and add it to all messages.
            return
        }
        #endregion Showing a Message
        if ($PSCmdlet.ParameterSetName -eq 'GameState') {
            Clear-Host
            if ($game.BackgroundColor) {
                # [Console]::Write(('' + [char]0x1b + '[1049l'))
                ([PSCustomObject]@{
                    PSTypeName='PowerArcade.Box'
                    BackgroundColor = $game.BackgroundColor
                } | Out-String -Width 1kb).Trim() | Write-Host -NoNewline
            }

            if ($game.CurrentLevel.Draw) {
                $Game.CurrentLevel.Draw()
            }
        }
    }

    end {
        if ($allMessages) { # If we have any messages to show
            # Pipe them to out string and write them to the console
            [Console]::Write("$(($allMessages | Out-String -Width 1kb).Trim())")
            [Console]::CursorVisible = $false # (don't forget to hide the cursor)
        }

        if ($passThru) { # If we're passing values thru
            if ($allMessages) { $allMessages.ToArray() } # return all messages
        }
    }
}