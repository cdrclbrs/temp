$Host.UI.RawUI.WindowTitle = "FATAL ERROR - SYSTEM COMPROMISED"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Red"
Clear-Host

$skull = @"   
                  ___-----------___
           __--~~                 ~~--__
       _-~~                             ~~-_
    _-~                                     ~-_
   /                                           \
  |                                             |
 |                                               |
 |                                               |
|                                                 |
|                                                 |
|                                                 |
 |                                               |
 |  |    _-------_               _-------_    |  |
 |  |  /~         ~\           /~         ~\  |  |
  ||  |             |         |             |  ||
  || |               |       |               | ||
  || |              |         |              | ||
  |   \_           /           \           _/   |
 |      ~~--_____-~    /~V~\    ~-_____--~~      |
 |                    |     |                    |
|                    |       |                    |
|                    |  /^\  |                    |
 |                    ~~   ~~                    |
  \_         _                       _         _/
    ~--____-~ ~\                   /~ ~-____--~
         \     /\                 /\     /
          \    | ( ,           , ) |    /
           |   | (~(__(  |  )__)~) |   |
            |   \/ (  (~~|~~)  ) \/   |
             |   |  [ [  |  ] ]  /   |
              |                     |
               \                   /
                ~-_             _-~
                   ~--___-___--~
"@

Write-Host $skull

# Message centré
Write-Host "`n      ######################################" -ForegroundColor Yellow
Write-Host "      #             PAWNED!!!              #" -ForegroundColor White -BackgroundColor Red
Write-Host "      ######################################`n" -ForegroundColor Yellow

# Boucle infinie pour empêcher la fermeture automatique
Write-Host "ENTER to QUIT..."
while($true) {
    Start-Sleep -Seconds 1
}
