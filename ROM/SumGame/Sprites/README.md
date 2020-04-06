## Understanding the Sprites directory
The Sprites directory defines the sprites used in the game.

Each Sprite is in it's own subdirectory.

Each subdirectory can have default properties (in SubDirectory/SubDirectory.psd1) and an initializer (in SubDirectory/SubDirectory.ps1)

All other .ps1 files in the subdirectory will become methods of the Sprite.

### OnTick.ps1 

Any Sprite directory can have an OnTick.ps1, which will be called when the game clock ticks.

### Collision files (+Target.ps1)

Any Sprite directory can also have one or more files starting with a +.  

These files describe what happens when the sprite collides with another sprite.

For instance, a file named Player\+Number.ps1 would describe what happens when a Player sprite hits a Number sprite.

Multiple collisions can be described in a single file by separating types with commas, 
for example: Player\+Number,Letter.ps1  would describe what happens when a Player sprite hits either a Number of a Letter.

A file named +.ps1 will describe all sprite collisions.
