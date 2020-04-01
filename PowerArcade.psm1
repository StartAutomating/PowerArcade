foreach ($file in Get-ChildItem $PSScriptRoot -Filter *-*.ps1 -Recurse) {
    . $file.Fullname
}


# Parts are simple .ps1 files beneath a /Parts directory that can be used throughout the module.
$partsDirectory = $( # Because we want to be case-insensitive, and because it's fast
    foreach ($dir in [IO.Directory]::GetDirectories($psScriptRoot)) { # [IO.Directory]::GetDirectories()
        if ($dir -imatch "\$([IO.Path]::DirectorySeparatorChar)Parts$") { # and some Regex
            [IO.DirectoryInfo]$dir;break # to find our parts directory.
        }
    })

if ($partsDirectory) { # If we have parts directory
    foreach ($partFile in $partsDirectory.EnumerateFileSystemInfos()) { # enumerate all of the files.
        if ($partFile.Extension -eq '.ps1') { # If it's a PowerShell script,
            $partName = # get the name of the script.
                $partFile.Name.Substring(0, $partFile.Name.Length - $partFile.Extension.Length)
            $ExecutionContext.SessionState.PSVariable.Set( # and set a variable
                $partName, # named the script that points to the script (e.g. $foo = gcm .\Parts\foo.ps1)
                $ExecutionContext.SessionState.InvokeCommand.GetCommand($partFile.Fullname, 'ExternalScript').ScriptBlock
            )
        }
    }
}

Set-Alias -Name _/\+  -Value Add-Sprite
Set-Alias -Name _/\-  -Value Remove-Sprite
Set-Alias -Name _/\-> -Value Move-Sprite


Export-ModuleMember -Alias * -Function *-*

