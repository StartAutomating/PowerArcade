function Find-Game
{
    <#
    .Synopsis
        Finds games
    .Description
        Finds games in the PowerShell Gallery
    .Example
        Find-Game
    .Link
        Get-Game
    .Link
        Install-Game
    #>
    [OutputType([PSObject])]
    param(
    # If provided, will only return games like this -Name.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Name,

    # If provided, will look for modules in a given -Repository.
    # If not provided, all registered repositories will be searched
    # Use Register-PSRepository to register a repository.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string[]]
    $Repository
    )

    process {
        #region Find Find-Module
        $findModuleCommand = $ExecutionContext.SessionState.InvokeCommand.GetCommand('Find-Module','All')
        if (-not $findModuleCommand) {
            Write-Error "Find-Module must exist in order to Find-Game"
            return
        }
        #region Find Find-Module

        #region Splatting Find-Module
        $findModuleSplat = @{}
        if ($Repository) {
            $findModuleSplat.Repository = $Repository
        }
        if ($name) {
            $findModuleSplat.Name = $name
        } else {
            $findModuleSplat.Tag = 'PowerArcade'
        }

        $foundModules = & $findModuleCommand @findModuleSplat
        #region Splatting Find-Module

        #region Make a Game out of you
        foreach ($fm in $foundModules) {
            [PSCustomOBject]([Ordered]@{
                Name=$fm.Name;
                Version = $fm.Version
                Description = $fm.Description
                Category = @(
                    $fm.Tags -like 'GameCategory:*' | Foreach-Object { @($_ -split ':', 2)[-1] }
                    $fm.Tags -eq 'Screensaver'
                )
                PSTypeName = 'PowerArcade.GameInfo'
            })
        }
        #endregion Make a Game out of you

    }
}
