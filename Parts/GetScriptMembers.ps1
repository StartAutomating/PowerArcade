param(
[Parameter(Mandatory)]
[IO.DirectoryInfo]
$Directory
)

$properties = [Ordered]@{}
foreach ($file in $Directory.GetFileSystemInfos()) {
    if ('.ps1', '.psd1','.json','.xml','.clixml','.csv' -notcontains $file.Extension) { continue }
    $fileName = $file.Name.Substring(0, $file.Name.Length - $file.Extension.Length)
    if ($file.Extension -eq '.ps1') {
        $methodScript = $ExecutionContext.SessionState.InvokeCommand.GetCommand($file.Fullname, 'ExternalScript').ScriptBlock
        if ($fileName -match '(?<GetSet>get|set)_') {
            $properties[$fileName] = $methodScript
            continue
        }
        $methodName = $fileName
        if ($methodName -eq $Directory.Name) {
            $methodName = 'Initialize'
        }

        [PSScriptMethod]::new($methodName, $methodScript)
        if ($methodName.StartsWith('+') -and $methodName.Contains(',')) {
            foreach ($aliasName in $methodName.TrimStart('+') -split ',') {
                [PSScriptMethod]::new("+$aliasName", $methodScript)
            }
        }
        continue
    }
    if ($fileName -eq $Directory.Name) {
        $fileName = 'Default'
    }
    [PSNoteProperty]::new($fileName, $(
        switch ($file.Extension) 
        {
            '.psd1' { 
                Import-LocalizedData -BaseDirectory $Directory.FullName -FileName $file.Name
            }
            '.csv' {
                Import-Csv -LiteralPath $file.Fullname 
            }
            '.json' {
                [IO.File]::ReadAllText($file.Fullname) | ConvertFrom-Json
            }
            '.xml' {
                [xml][IO.File]::ReadAllText($file.Fullname)
            }
            '.clixml' {
                Import-Clixml -LiteralPath $file.Fullname
            }
        }
    ))
}

$alreadyGotIt = @()
foreach ($pv in $properties.GetEnumerator()) {
    if ($alreadyGotIt -contains $pv.Key) { continue }
    $propName = "$($pv.Key)".Substring(4)
    $alreadyGotIt += $pv.Key
    if ($pv.Key -like 'get_*') {
        if ($properties["set_$propName"]) {
            $alreadyGotIt += "set_$propName"
            [PSScriptProperty]::new($propName, $pv.Value, $properties["set_$propName"])
        } else {
            [PSScriptProperty]::new($propName, $pv.Value)
        }
    } else {
        [PSScriptProperty]::new($propName, {}, $pv.Value)
    }
}