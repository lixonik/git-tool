@echo off
rem GitTool launcher: IntelliJ IDEA Community restricted to git tooling,
rem fully isolated from any regular IDEA installation.
set "GITTOOL_ROOT=%~dp0"
set "IDEA_PROPERTIES=%GITTOOL_ROOT%gittool.properties"
set "IDEA_VM_OPTIONS=%GITTOOL_ROOT%gittool.vmoptions"
start "" "%GITTOOL_ROOT%dist\bin\idea64.exe" %*
