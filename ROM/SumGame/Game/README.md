## Understanding the Game Directory

The Game Directory contains methods and data used throughout the game.

Any .PS1 file located in this directory will become a ScriptMethod on the game.

Any .PSD1 file located in this directory will become a Property on the game object.


## Special Files


### Initialize and Default

A Script Named Game.PS1 will become a method named Initialize(), 
which will be called when the game is initialized.

A Data File Named Game.PSD1 will become a property named Default, 
and this will set the default properties for the game object.

### OnTick

A Script Named OnTick.ps1 will be called whenever the game clock ticks.


### OnKey

Keys can be trapped anywhere in the Game by defining files named OnKey_NameOfKey.ps1

A Script Named OnKey_Any.ps1 or OnKey_All.ps1 will be called whenever any key is pressed.  

If this script is provided, all key events must be handled within it.

Otherwise, specific key named can be trapped with OnKey_NameOfKey.ps1