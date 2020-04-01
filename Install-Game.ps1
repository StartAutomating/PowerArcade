function Install-Game
{
    <#
    .Synopsis
        Installs a Game from the PowerShell Gallery
    .Description
        Installs a Game from the PowerShell Gallery to the PowerArcade ROM directory.
    .Link
        Get-Game
    .Example
        Install-Game -Name Blackjack
    .Example
        Find-Game -Name ShuffleScreen | Install-Game
    #>
    [OutputType([Nullable])]
    param(
    # The name of the game module.
    [Parameter(Mandatory,ValueFromPipelineByPropertyName,Position=0)]
    [string]
    $Name,

    # The repository.  If this is not provided, all default registered repositories will be contacted.
    [Parameter(ValueFromPipelineByPropertyName,Position=0)]
    [string]
    $Repository
    )

    process {
        #region Where to?
        $saveTo = $profile |
            Split-Path |
            Join-Path -ChildPath PowerArcade |
            Join-Path -ChildPath ROM
        #endregion Where to?

        #region Is it Safe?
        if (-not (Test-Path $saveTo)) {
            $createdDirectory = New-Item -ItemType Directory -Path $saveTo -Force
            if (-not $createdDirectory) {
                return
            }
        }
        #endregion Is it Safe?

        #region Save the Module, Save the World
        $saveModuleSplat = @{Path=$saveTo} + $PSBoundParameters
        Save-Module @saveModuleSplat
        #endregion Save the Module, Save the World
    }
}
