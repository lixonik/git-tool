@echo off
rem GitTool installer: copies the portable package to %LOCALAPPDATA%\GitTool,
rem creates a desktop shortcut and launches the tool.
setlocal
set "TARGET=%LOCALAPPDATA%\GitTool"
echo Installing GitTool to %TARGET% ...
robocopy "%~dp0GitToolMini" "%TARGET%" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo Copy failed.
  pause
  exit /b 1
)
powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\GitTool.lnk');$s.TargetPath='%TARGET%\GitTool.bat';$s.WorkingDirectory='%TARGET%';$s.IconLocation='%TARGET%\dist\bin\gittool64.exe';$s.Save()"
echo Done.
start "" "%TARGET%\GitTool.bat"
endlocal
