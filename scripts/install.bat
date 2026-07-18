@echo off
rem GitTool installer: copies the portable package to %LOCALAPPDATA%\GitTool,
rem creates Desktop and Start Menu shortcuts pointing at the native
rem gittool64.exe (self-sufficient: config paths ship in dist\bin\idea.properties),
rem then launches the tool.
setlocal
set "TARGET=%LOCALAPPDATA%\GitTool"
set "EXE=%TARGET%\dist\bin\gittool64.exe"
echo Installing GitTool to %TARGET% ...
robocopy "%~dp0GitToolMini" "%TARGET%" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo Copy failed.
  pause
  exit /b 1
)
powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; foreach ($dir in @([Environment]::GetFolderPath('Desktop'), (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Microsoft\Windows\Start Menu\Programs'))) { $s = $ws.CreateShortcut((Join-Path $dir 'GitTool.lnk')); $s.TargetPath = '%EXE%'; $s.WorkingDirectory = '%TARGET%'; $s.IconLocation = '%EXE%'; $s.Save() }"
echo Done.
start "" "%EXE%"
endlocal
