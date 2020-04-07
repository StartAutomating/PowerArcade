function New-Sprite
{
    <#
    .Synopsis
        Creates Sprites
    .Description
        Creates a new Sprite.
    .Example
        New-Sprite -X 10 -Y 20 -Content '!' -Color "#ff0000"
    .Link
        Add-Sprite
    .Link
        Find-Sprite
    .Link
        Move-Sprite
    .Link
        Remove-Sprite
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="This does not change state, it creates an object")]
    param(
    # The type of the sprite.  The sprite type is used to group sprites and handle specific collisions.
    [Parameter(Position=0,ValueFromPipelineByPropertyName)]
    [string]
    $Type,

    # The X coordinate of the sprite.
    # If the X coordinate would not be visible, the sprite will not be rendered
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $X,

    # The X coordinate of the sprite.
    # If the Y coordinate would not be visible, the sprite will not be rendered
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Y,

    # The name of the sprite.
    # Giving a sprite a name will declare it as a global variable.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Name,

    # The sprite content.  This can be used for sprites that are a single line.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Content,

    # The sprite color.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $Color,

    # The sprite background color.
    [Parameter(ValueFromPipelineByPropertyName)]
    [string]
    $BackgroundColor,

    # The width of the sprite.
    # Supplying this and -Height will make the sprite a rectangle.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Width,

    # The height of the sprite
    # Supplying this and -Width will make the sprite a rectangle.
    [Parameter(ValueFromPipelineByPropertyName)]
    [int]
    $Height,

    # Additional properties of the sprite.
    # This can contain any custom information.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Alias('Properties')]
    [Collections.IDictionary]
    $Property,

    # Additional methods for the sprite
    # These can be used to dynamically create sprite behavior.
    [Parameter(ValueFromPipelineByPropertyName)]
    [Collections.IDictionary]
    $Method)

    process {
        $out = [PSCustomObject]([Ordered]@{
            SpriteID = [BitConverter]::ToString([GUID]::NewGuid().ToByteArray()).Replace('-','').ToLower()
        } + $PSBoundParameters)
        $out.pstypenames.clear()
        $out.pstypenames.add("PowerArcade.Sprite")
        if ($out.Width -and $out.Height) {
            $out.psobject.Members.Add([PSNoteProperty]::new('Shapes',@(
                $shape = [PSCustomObject]@{PSTypeName='PowerArcade.Box';Width=$out.Width;Height=$out.Height}
                $shape.psobject.Members.Add([PSNoteProperty]::new('Sprite',$out))
                $shape.psobject.Members.Add([PSScriptProperty]::new('X', { $this.Sprite.X}))
                $shape.psobject.Members.Add([PSScriptProperty]::new('Y', { $this.Sprite.Y}))
                $shape.psobject.Members.Add([PSScriptProperty]::new('BackgroundColor', { $this.Sprite.BackgroundColor}))
                $shape.psobject.Members.Add([PSScriptProperty]::new('Color', { $this.Sprite.Color}))
                $shape
            )))
        }
        if ($Type) {
            if ($Game.SpriteTypes.$Type) {
                foreach ($member in $game.SpriteTypes.$type.psobject.Members) {
                    $out.psobject.Members.Add($member, $true)
                }
            }

            if ($out.Default -is [Collections.IDictionary]) {
                foreach ($kv in $out.Default.GetEnumerator()) {
                    if (-not $out.($kv.Key)) {
                        $out.psobject.members.Add([PSNoteProperty]::new($kv.Key,$kv.Value), $true)
                    }
                }
            }
            $out.pstypenames.add("$Type.Sprite")
        }
        if ($Property) {
            foreach ($kv in $Property.GetEnumerator()) {
                $out.psobject.members.add([PSNoteProperty]::new($kv.Key,$kv.Value))
            }
        }
        if ($Method) {
            foreach ($kv in $Method.GetEnumerator()) {
                $out.psobject.members.add([PSScriptMethod]::new($kv.Key, $kv.Value))
            }
        }
        if ($out.Initialize.Invoke) {
            $out.Initialize()
        }
        $out
    }
}
