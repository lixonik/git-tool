<#
  Packages an installed GitToolMini (custom minimal product) into distributable
  artifacts: a portable .7z and a self-extracting setup .exe.

  The setup exe = 7z.sfx + sfx-config.txt + archive. On the target PC it
  unpacks to %TEMP%, runs install.bat (copies to %LOCALAPPDATA%\GitTool,
  creates a desktop shortcut, launches the tool).

  Prerequisites: 7-Zip x64 (7z.exe + 7z.dll + 7z.sfx). If absent, obtain
  portable: download 7zr.exe and the full installer from 7-zip.org, then
  extract the installer with 7zr (it is itself an SFX archive).

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\make-release.ps1 `
      [-SourceRoot D:\Apps\GitToolMini] [-OutDir D:\Apps\GitTool-release] `
      [-SevenZipDir D:\Apps\7z-tools\full]
#>
param(
  [string]$SourceRoot = 'D:\Apps\GitToolMini',
  [string]$OutDir = 'D:\Apps\GitTool-release',
  [string]$SevenZipDir = 'D:\Apps\7z-tools\full',
  [string]$Version = '262'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$sevenZip = Join-Path $SevenZipDir '7z.exe'
$sfxModule = Join-Path $SevenZipDir '7z.sfx'
foreach ($f in @($sevenZip, $sfxModule)) { if (-not (Test-Path $f)) { throw "Missing: $f" } }
if (-not (Test-Path (Join-Path $SourceRoot 'dist\bin\gittool64.exe'))) { throw "GitToolMini not found at $SourceRoot" }

New-Item -ItemType Directory -Force $OutDir | Out-Null
$archive = Join-Path $OutDir "GitTool-$Version-portable.7z"
$setupExe = Join-Path $OutDir "GitTool-$Version-setup.exe"
if (Test-Path $archive) { Remove-Item $archive -Force }

$parent = Split-Path $SourceRoot -Parent
$name = Split-Path $SourceRoot -Leaf
Push-Location $parent
& $sevenZip a -t7z $archive "$name\dist" "$name\config" "$name\mingit" '-xr!system' '-xr!*.log' '-mx=5' '-mmt=16'
Pop-Location
if ($LASTEXITCODE -ne 0) { throw '7z packing failed' }

Push-Location (Split-Path $PSScriptRoot -Parent)
& $sevenZip a $archive (Join-Path $PSScriptRoot 'install.bat')
Pop-Location

cmd /c "copy /b `"$sfxModule`" + `"$(Join-Path $PSScriptRoot 'sfx-config.txt')`" + `"$archive`" `"$setupExe`"" | Out-Null
& $sevenZip t $setupExe
if ($LASTEXITCODE -ne 0) { throw 'setup exe integrity check failed' }

Write-Host "Done:"
Write-Host "  portable: $archive"
Write-Host "  setup:    $setupExe"
