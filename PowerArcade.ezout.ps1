#requires -Module EZOut
#  Install-Module EZOut or https://github.com/StartAutomating/EZOut
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "", Justification="Games are Global")]
param()
$myFile = $MyInvocation.MyCommand.ScriptBlock.File
$myModuleName = $($myFile | Split-Path -Leaf) -replace '\.ezout\.ps1', ''
$myRoot = $myFile | Split-Path
Push-Location $myRoot
$formatting = @(
    # Add your own Write-FormatView here, or put them in a Formatting or Views directory

    foreach ($potentialDirectory in 'Formatting','Views') {
        Join-Path $myRoot $potentialDirectory |
            Get-ChildItem -ea ignore |
            Import-FormatView -FilePath {$_.Fullname}
    }
)

if ($formatting) {
    $myFormatFile = Join-Path $myRoot "$myModuleName.format.ps1xml"
    $formatting | Out-FormatData -Module $MyModuleName | Set-Content $myFormatFile -Encoding UTF8
}

$types = @(
    # Add your own Write-TypeView statements here
    Join-Path $myRoot 'Types' |
        Get-Item -ErrorAction Ignore |
        Import-TypeView

    Write-TypeView -TypeName PowerArcade.CurrentLevel -HideProperty SpriteMap -DefaultDisplay Name, IsCurrentLevel -ScriptProperty @{
        IsCurrentLevel = {
            if (-not $Global:Game) { return $false }
            return $Global:Game.CurrentLevel -eq $this
        }
    }
)

if ($types) {
    $myTypesFile = Join-Path $myRoot "$myModuleName.types.ps1xml"
    $types | Out-TypeData | Set-Content $myTypesFile -Encoding UTF8
}
Pop-Location
