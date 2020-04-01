
$designs = @{
    0 = @'
┌─────────┐
│▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒│
│▒▒▒▒▒▒▒▒▒│ 
│▒▒▒▒▒▒▒▒▒│
└─────────┘
'@
        1 = @'
┌─────────┐
│A♣       │
│         │
│         │
│    ♣    │
│         │
│         │ 
│       ♣A│
└─────────┘
'@
        2= @'
┌─────────┐
│2♣       │
│    ♣    │
│         │
│         │
│         │
│    ♣    │ 
│       ♣2│
└─────────┘
'@
        3= @'
┌─────────┐
│3♣       │
│   ♣     │
│         │
│    ♣    │
│         │
│     ♣   │
│       ♣3│
└─────────┘
'@
        4 = @'
┌─────────┐
│4♣       │
│   ♣ ♣   │
│         │
│         │
│         │
│   ♣ ♣   │
│       ♣4│
└─────────┘
'@
    5 = @'
┌─────────┐
│5♣       │
│   ♣ ♣   │
│         │
│    ♣    │
│         │
│   ♣ ♣   │
│       ♣5│
└─────────┘
'@
    6 = @'
┌─────────┐
│6♣       │
│   ♣ ♣   │
│         │
│   ♣ ♣   │
│         │
│   ♣ ♣   │
│       ♣6│
└─────────┘
'@

    7 = @'
┌─────────┐
│7♣       │
│   ♣ ♣   │
│         │
│  ♣ ♣ ♣  │
│         │
│   ♣ ♣   │
│       ♣7│
└─────────┘
'@
    8 = @'
┌─────────┐
│8♣       │
│  ♣ ♣ ♣  │
│         │
│  ♣   ♣  │
│         │
│  ♣ ♣ ♣  │
│       ♣8│
└─────────┘
'@
    9= @'
┌─────────┐
│9♣       │
│  ♣ ♣ ♣  │
│         │
│  ♣ ♣ ♣  │
│         │
│  ♣ ♣ ♣  │
│       ♣9│
└─────────┘
'@
    10 = @'
┌─────────┐
│10♣      │
│  ♣ ♣ ♣  │
│    ♣    │
│  ♣   ♣  │
│    ♣    │
│  ♣ ♣ ♣  │
│      ♣10│
└─────────┘
'@
    11= @'
┌─────────┐
│J♣       │
│     ♣   │
│     ♣   │
│     ♣   │
│   ♣ ♣   │
│    ♣    │
│       ♣J│
└─────────┘
'@
    12= @'
┌─────────┐
│Q♣       │
│   ♣♣♣   │
│  ♣   ♣  │
│  ♣   ♣  │
│  ♣   ♣  │
│   ♣♣♣   │
│      ♣♣Q│
└─────────┘
'@
    13= @'
┌─────────┐
│K♣       │
│  ♣   ♣  │
│  ♣  ♣   │
│  ♣♣♣    │
│  ♣  ♣   │
│  ♣   ♣  │
│       ♣K│
└─────────┘
'@

}


$card = $_
$realSuite = 
    if ($card.Suite -eq '♣' -or $card.Suite -eq 'Clubs' -or $card.Suite -eq 1) 
    {
        '♣'
    } 
    elseif ($card.Suite -eq '♦' -or $card.Suite -eq 'Diamonds' -or $card.Suite -eq 2) 
    {
        '♦'
    }
    elseif ($card.Suite -eq '♥' -or $card.Suite -eq 'Hearts' -or $card.Suite -eq 3) 
    {
        '♥'
    }
    elseif ($card.Suite -eq '♠' -or $card.Suite -eq 'Spades' -or $card.Suite -eq 4) 
    {
        '♠'
    }

    $cardNumber = $card.Number -as [int]
    if (-not $cardNumber) {
        if ($card.Number -eq 'Ace') {
            $cardNumber = 1
        } elseif ($card.Number -eq 'Jack') {
            $cardNumber = 11
        } elseif ($card.Number -eq 'Queen') {
            $cardNumber = 12
        } elseif ($card.Number -eq 'King') {
            $cardNumber = 13
        }
    }
    if (-not $designs[$cardNumber]) {
        throw "$($card.Number) not found"
    }
if (-not $Host.UI.SupportsVirtualTerminal) {
    return $designs[$cardNumber] -replace '♣', $realSuite
} else {
    @(
        
        '' + [char]0x1b+"[48;2;255;255;255m"
        if ('♣', '♠' -contains $realSuite) {
            '' + [char]0x1b+"[38;2;0;0;0m"
        } else {
            '' + [char]0x1b+"[38;2;255;0;0m"
        }
        if ($card.Selected) {
            '' + [char]0x1b + '[7m'
        }
        if ($card.X -ge 0 -and $card.Y -ge 0) {
            $designLines = $designs[$cardNumber] -replace '♣', $realSuite -split '(?>\r\n|\n)'
            $y = $card.Y
            foreach ($dl in $designLines) {
                '' + [char]0x1b + "[$($Y);$($card.X)H"
                $dl.Trim()
                $y++
            }
        } else {
            $designs[$cardNumber] -replace '♣', $realSuite
        }
        if ($card.Selected) {
            '' + [char]0x1b + '[27m'
        }
        '' + [char]0x1b +'[39m'
        '' + [char]0x1b +'[49m'
    ) -join ''
}
