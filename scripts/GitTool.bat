@echo off
rem GitTool launcher: IntelliJ IDEA Community restricted to git tooling,
rem fully isolated from any regular IDEA installation.
rem
rem Release distributions ship product-info.json and are launched through the
rem native idea64.exe (clean GUI, no console). A from-source build omits that
rem file (its build target skips the packaging step), so it is launched through
rem the script launcher idea.bat in its own window.
setlocal
set "GITTOOL_ROOT=%~dp0"
set "IDEA_PROPERTIES=%GITTOOL_ROOT%gittool.properties"
set "IDEA_VM_OPTIONS=%GITTOOL_ROOT%gittool.vmoptions"

if exist "%GITTOOL_ROOT%dist\product-info.json" (
  start "" "%GITTOOL_ROOT%dist\bin\idea64.exe" %*
) else (
  start "GitTool" /min "%GITTOOL_ROOT%dist\bin\idea.bat" %*
)
endlocal
