######################################################################################################################################################################
#                                             |                                                                   |             .'''''.        ..||..'''''''...      #
# -Title     :Kill_Wallpaper                  |                                                                   |            / ##### \       : ||            ''.   #
# -Author    :ItsIsaac                        |                                                                   |           | ## # ## |      :.||...''''''....  '. #
# -Version   :1.2                             |                                                                   |           | #  #  # |        ||             '''' &
# -Category  :Kill Wallpaper Engine           |       .___  __           .___                                     |            \ ##### /     /| < _>                 #
# -Target    :W 10/11                         |       |   |/  |_  ______ |   | ___________  _____    ____         |             \ ### /     / |/ < _>                #
# -Mode:     :HID                             |       |   \   __\/  ___/ |   |/  ___/\__  \ \__  \ _/ ___\        |           ..''   ''... /  |  < _>                #
#                                             |       |   ||  |  \___ \  |   |\___ \  / __ \_/ __ \\  \___        |         .'            /   | /||                  #
#                                             |       |___||__| /____  > |___/____  >(____  (____  /\___  >       |         '                 |/ ||                  #
#                                             |                      \/           \/      \/     \/     \/        |         |   |     '..     |  ||                  # 
#                                             |                                                                   |         |   |     |  '...''  ||                  #
#_____________________________________________|___________________________________________________________________|         |  |       |         ||                  #
#                                                                                                                 |          \ |       |         ||                  # 
#                                                                                                                 |          |\|       |         ||                  #
#                                                                                                                 |          \|         |        ||                  #
#                                                                                                                 |           |         |        ||                  #
#                                                                                                                 |           |         |        ||                  #
#                                                                                                                 |          |           |       ||                  #
#                                                                                                                 |        __|           |__     ||                  #
#                                                                                                                 |       /   '.........'   \    ||                  #
#                                                                                                                 |        ''''''     ''''''     ##                  #
######################################################################################################################################################################
<#
#Turn off wallpaper engine
#Get process information
  $wpProcess = Get-Process -Name wallpaper* -ErrorAction SilentlyContinue
  
if ($wpProcess -ne $null) {

  #Assign the process ID to a variable
  #$wpID = $wpProcess.Id
  
  #Stop process
  Stop-Process -Id (Get-Process wallpaper*).Id -Force
  
}else{

  Exit
}
#>
Stop-Process -Id (Get-Process wallpaper*).Id -Force -ErrorAction SilentlyContinue
