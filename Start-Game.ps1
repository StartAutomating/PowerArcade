function Start-Game
{
    <#
    .Synopsis
        Starts a Game
    .Description
        Starts a Game.
    .Link
        Initialize-Game
    .Link
        Watch-Game
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='Low')]
    [OutputType([Nullable])]
    param(
    # The path to the game
    [Parameter(Mandatory,Position=0,ParameterSetName='GamePath',ValueFromPipelineByPropertyName)]
    [Alias('ROM','FullName')]
    [string]
    $GamePath,

    # The level
    [string]
    $Level
    )



    process {
        #region Find that Game

        $resolvePathError = $null
        $resolvedGamePath =
            try { $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($gamePath) }
            catch { $resolvePathError = $_ }
        if (-not $resolvedGamePath) { # If we can't resolve the gamepath,
            # see if there's an installed game by that name.
            $resolvedGamePath = Get-Game -Name $GamePath | Select-Object -First 1 -ExpandProperty GamePath
            if (-not $resolvedGamePath) { # If we still couldn't resolve the game path,
                $PSCmdlet.WriteError($resolvePathError) # error out
                return
            }

        }
        if ($resolvedGamePath -like '*.ps1') { # If the gamepath was a specific ps1 file, run it and return
            # (this lets 'legacy' games, like PSInvaders, run)
            & $resolvedGamePath
            return
        }
        #endregion Find that Game

        # Make sure they want to run a game from there.
        if (-not $PSCmdlet.ShouldProcess("Running Game from $resolvedGamePath")) { return }

        #region ISE is not cool enough
        if ($host.Name -eq 'Windows PowerShell ISE Host') {
            Write-Warning "ISE may be cool, but it can't play.  Launching the console.  It will quit when done."
            $powerShellArgs = @(
                '-windowstyle'
                'maximized'
                '-noexit'
                '-command'
                'Import-Module PowerArcade -Force -PassThru; Start-Game ' +
                $(@(
                    foreach ($kv in $PSBoundParameters.GetEnumerator()) {
                        if ($kv.Value -is [string]) {
                            "-$($kv.Key)"
                            "'$($kv.Value.Replace("'","''"))'"
                        }
                    }
                ) -join ' ') + ';if ($?) { exit }'

            )
            Start-Process powershell -ArgumentList $powerShellArgs -WorkingDirectory $pwd
            return
        }
        #endregion ISE is not cool enough

        #region Start it up
        $theGame = Initialize-Game -GamePath $resolvedGamePath -Level $level |
            Where-Object { $_.PSTypeNames -contains 'PowerArcade.Game' } |
            Select-Object -First 1
        $theGame |
            Add-Member NoteProperty IsRunning $true -Force -PassThru |
            Add-Member ScriptMethod Exit { $this.IsRunning = $false } -Force
        #endregion Start it up
        #region Watch the game
        if ($theGame) {
            $theGame | Watch-Game
        }
        #endregion Watch the game
    }
}
