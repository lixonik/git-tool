@echo off
rem GitTool launcher: IntelliJ IDEA Community restricted to git tooling,
rem fully isolated from any regular IDEA installation.
rem
rem A release distribution ships a product-info.json that the native idea64.exe
rem accepts, giving a clean GUI with no console. A from-source build's packaging
rem step is skipped, so its product-info.json is synthesized for the Java-side
rem PathManager (which idea.bat needs) but the stricter native launcher rejects
rem it; such installs carry a .gittool-script-launcher marker and are started
rem through idea.bat. Its stdout/stderr are redirected to a file because, left
rem attached to a background/minimized console, the JVM blocks on console I/O
rem during bootstrap.
setlocal
set "GITTOOL_ROOT=%~dp0"
set "IDEA_PROPERTIES=%GITTOOL_ROOT%gittool.properties"
set "IDEA_VM_OPTIONS=%GITTOOL_ROOT%gittool.vmoptions"

if exist "%GITTOOL_ROOT%dist\.gittool-script-launcher" (
  start "GitTool" /min cmd /c ""%GITTOOL_ROOT%dist\bin\idea.bat" %* > "%GITTOOL_ROOT%launch.log" 2>&1"
) else (
  start "" "%GITTOOL_ROOT%dist\bin\idea64.exe" %*
)
endlocal
