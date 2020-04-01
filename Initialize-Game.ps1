function Initialize-Game
{
    <#
    .Synopsis
        Initializes a game
    .Description
        Initializes the global variable $game with the game logic contains within a -GamePath.
    .Link
        Start-Game
    .Link
        Initialize-Level
    .Link
        Initialize-Sprite
    .Example
        # Initializes Nibbles2020, when run from PowerArcade's module root.
        Initialize-Game -GamePath .\ROM\Nibbles2020
    #>
    [CmdletBinding(DefaultParameterSetName='GameModule')]
    param(
    # The path to the game.  This path should contain a module, and 'Game','Levels',and 'Sprites' subdirectories.
    [Parameter(Mandatory,Position=0,ValueFromPipelineByPropertyName,ParameterSetName='GamePath')]
    [Alias('ROM','FullName')]
    [string]
    $GamePath,

    # The game module
    [Parameter(Mandatory,Position=0,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName='GameModule')]
    [Management.Automation.PSModuleInfo]
    $Module,

    # The level to the game will start.
    # If not provided, will use the default from the game.psd1.
    # If no default is found, will start at the first defined level.
    [Alias('Level')]
    [string]
    $StartLevel,

    # If set, will not clear the screen, clear the spritemap, and clear the sprite list
    [Alias('DoNotClear')]
    [switch]
    $NoClear
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'GamePath') {

            $resolvedGamePath = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($gamePath)
            if (-not $resolvedGamePath) { return }
            if ($resolvedGamePath -like '*.ps1') {

                return
            }

            $gamePathItem = Get-Item -LiteralPath $resolvedGamePath
            if ($resolvedGamePath -notlike '*.psd1') {
                if ($gamePathItem -is [IO.DirectoryInfo]) {
                    $psd1Name =
                    if ($gamePathItem.Name -as [Version]) {
                        $gamePathItem.Parent.Name
                    } else {
                        $gamePathItem.Name
                    }
                    foreach ($file in $gamePathItem.GetFileSystemInfos()) {
                        if ($file.Name -eq "$psd1Name.psd1") {
                            $gamePathItem = $file
                            break
                        }
                    }
                    if ($gamePathItem -is [IO.DirectoryInfo]) {
                        return
                    }
                } else {
                    return
                }
            }

            if ($GamePathItem.Name -notlike '*.psd1') {
                Write-Verbose "Skipping $GamePath because it is not a manifest file"
                return
            }

            $toSplat = @{} + $PSBoundParameters
            $toSplat.Remove('GamePath')
            Import-Module $gamePathItem.Fullname -Force -PassThru | Initialize-Game @toSplat

            return
        }

        $gameModuleDirectory = $Module | Split-Path | Get-Item
        if (-not $gameModuleDirectory) { return }

        foreach ($fsi in $GameModuleDirectory.GetFileSystemInfos()) {
            if ($fsi -isnot [IO.DirectoryInfo]) {
                continue
            }


            if ($fsi.Name -eq 'Game') {
                # Game-wide content



                $global:Game = [PSCustomObject]@{
                    Name = $Module.Name
                    Version = $module.Version
                    Root = $Module | Split-Path
                    CurrentLevel = $null
                    CurrentLevelName = ''
                    Clock = '00:00:00.01'
                    Levels = [Ordered]@{}
                    SpriteTypes = [Ordered]@{}
                }
                foreach ($member in & $GetScriptMembers $fsi) {
                    $game.psobject.members.add($member)
                }
                if ($game.Default) {
                    if ($game.Default -is [Collections.IDictionary]) {
                        foreach ($kv in $game.Default.GetEnumerator()) {
                            $game.psobject.members.add(
                                [PSNoteProperty]::new($kv.Key, $kv.Value),
                                $true
                            )
                        }
                    }
                }

                if (-not $game.Width) {
                    $Game | Add-Member NoteProperty Width $host.UI.RawUI.WindowSize.Width -Force
                }

                if (-not $game.Height) {
                    $Game | Add-Member NoteProperty Height $host.UI.RawUI.WindowSize.Height -Force
                }

                if (-not $game.CellWidth) {
                    $game | Add-Member NoteProperty CellWidth ([Math]::Ceiling([Math]::Sqrt($game.Width)))
                }
                if (-not $game.CellHeight) {

                    $game | Add-Member NoteProperty CellHeight ([Math]::Ceiling([Math]::Sqrt($game.Height)))
                }

                $game.pstypenames.clear()
                $game.pstypenames.add('PowerArcade.Game')

            }
        }

        $game | Initialize-Level
        $game | Initialize-Sprite

        if ($game.Initialize.Invoke) {
            $game.Initialize()
        }

        if (-not $StartLevel) {
            $startLevel = @($game.StartLevel, $game.StartingLevel, $game.DefaultLevel -ne $null -ne '')[0]
        }
        if (-not $StartLevel) {
            $StartLevel = @($game.Levels.GetEnumerator())[0].Key
        }



        $global:Game = $game

        if ($StartLevel) {
            Switch-Level -Level $startLevel -NoClear:$NoClear
        }
        $game
    }
}
