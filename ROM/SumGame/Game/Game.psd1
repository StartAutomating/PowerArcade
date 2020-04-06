@{
    # The Background Color of the game (most games should set this)
    BackgroundColor = '#000000'  

    # The Text Color of the game (most games should set this, it's used in MessageBoxes by default)
    TextColor = '#00ff00'

    # The Level the game starts on (most games should set this.  If they don't, the first alphabetically named Level will be used.
    StartLevel = 'Menu'

    # An ASCII art logo.  This is not required, but having one makes implementing a Menu easy
    Logo = @'

  _________               ________                        
 /   _____/__ __  _____  /  _____/_____    _____   ____   
 \_____  \|  |  \/     \/   \  ___\__  \  /     \_/ __ \  
 /        \  |  /  Y Y  \    \_\  \/ __ \|  Y Y  \  ___/  
/_______  /____/|__|_|  /\______  (____  /__|_|  /\___  > 
        \/            \/        \/     \/      \/     \/  
'@

    # Instructions on how to play the game.
    # This is not required, but having them makes implementing a Menu easy.
    Instructions = 
        'Eat Numbers until you reach the total',
        'If you eat too much,',
        ' eat a negative number to subtract'

    # The game controls.
    # This is not required, but having them makes implementing a Menu easy.
    Controls = 
        'Space  - Start',
        'Arrows - Move',
        'Escape - Quit'
}