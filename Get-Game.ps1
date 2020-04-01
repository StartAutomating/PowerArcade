function Get-Game
{
    <#
    .Synopsis
        Gets installed games
    .Description
        Gets installed PowerArcade games.

        PowerArcade games are installed to a ROM folder in the PowerArcade directory
        The PowerArcade directory is located in the same folder as the user's $profile
    .Example
        Get-Game
    .Link
        Find-Game
    .Link
        Install-Game
    .Link
        Start-Game
    #>
    param(
    # If provided, will only return games like this -Name.
    [string]
    $Name,

    # If provided, will only return games like this -Cateogry.
    [string]
    $Category
    )


    $gameRomDirectories = @(
        $profile |
            Split-Path |
            Join-Path -ChildPath PowerArcade |
            Join-Path -ChildPath ROM

        $MyInvocation.MyCommand.ScriptBlock.File |
            Split-Path |
            Join-Path -ChildPath ROM
    )

    $gameDirectories = $gameRomDirectories |
        Get-Item -ErrorAction Ignore |
        Get-ChildItem -Directory

    foreach ($gameDirectory in $gameDirectories) {
        $realDirectory  =$gameDirectory
        $gamePsd1 = @{FileName = $gameDirectory.Name + '.psd1';ErrorAction='Ignore'}
        $psd1 = try { Import-LocalizedData -BaseDirectory $gameDirectory.FullName @gamePsd1 } catch {$null }
        if (-not $psd1) {
            $mostRecentVersionDirectory =
                $gameDirectory |
                    Get-ChildItem -Directory |
                    Where-Object {$_.Name -as [Version] } |
                    Sort-Object { $_.Name -as [Version] } -Descending |
                    Select-Object -First 1
            $psd1 =
                try { Import-LocalizedData -BaseDirectory $mostRecentVersionDirectory.FullName @gamePsd1 }
                catch {$null }
            if (-not $psd1) {
                Write-Verbose "Could not find $($gamePSD1.FileName) game in $($gameDirectory.Name)"
                continue
            } else {
                $realDirectory = $mostRecentVersionDirectory
            }
        }

        $tags = @() + $psd1.PrivateData.PSData.Tags
        $gotGame = [PSCustomOBject]([Ordered]@{
            Name=$gameDirectory.Name
            Version = $psd1.ModuleVersion -as [Version]
            Description = $psd1.Description
            Category = @(
                $tags -like 'GameCategory:*' | Foreach-Object { @($_ -split ':', 2)[-1] }
                $tags -eq 'Screensaver'
            )
            ModuleManifest = $psd1
            GamePath = $realDirectory.Fullname
            PSTypeName = 'PowerArcade.GameInfo'
        })

        if ($name -and ($gotGame.Name -notlike $name)) { continue }
        if ($Category -and -not ($gotGame.Category -like $Category)) { continue }
        $gotGame
    }
}
