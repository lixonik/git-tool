<#
  Builds the Linux self-extracting installer from the product's linux tar.gz.
  Assembly runs inside WSL to preserve unix file modes in the repacked payload.

  Steps: extract build artifact -> inject config-template (Classic UI plugin,
  trimmed-menus customization.xml) -> retar -> concatenate with installer
  header script.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\make-release-linux.ps1 `
      [-Artifact D:\Repos\intellij-community\out\gittool\artifacts\gittool-262.SNAPSHOT.tar.gz] `
      [-ClassicUiDir D:\Apps\GitToolMini\config\plugins\classic-ui] `
      [-OutDir D:\Apps\GitTool-release] [-Version 262]
#>
param(
  [string]$Artifact = 'D:\Repos\intellij-community\out\gittool\artifacts\gittool-262.SNAPSHOT.tar.gz',
  [string]$ClassicUiDir = 'D:\Apps\GitToolMini\config\plugins\classic-ui',
  [string]$OutDir = 'D:\Apps\GitTool-release',
  [string]$Version = '262',
  [string]$WslDistro = 'Ubuntu'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
foreach ($f in @($Artifact, $ClassicUiDir, (Join-Path $PSScriptRoot 'installer-linux.sh'))) {
  if (-not (Test-Path $f)) { throw "Missing: $f" }
}
New-Item -ItemType Directory -Force $OutDir | Out-Null

function To-WslPath([string]$p) { '/mnt/' + $p.Substring(0,1).ToLower() + ($p.Substring(2) -replace '\\','/') }

$stage = Join-Path $env:TEMP 'gittool-linux-stage'
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force "$stage\config-template\options" | Out-Null
Copy-Item $ClassicUiDir "$stage\config-template\plugins\classic-ui" -Recurse -Force
Copy-Item (Join-Path $RepoRoot 'config\options\customization.xml') "$stage\config-template\options" -Force

$wArtifact = To-WslPath $Artifact
$wStage = To-WslPath $stage
$wHeader = To-WslPath (Join-Path $PSScriptRoot 'installer-linux.sh')
$installer = Join-Path $OutDir "GitTool-$Version-linux-x64-installer.sh"
$wInstaller = To-WslPath $installer

$script = @"
set -e
work=`$(mktemp -d)
tar xzf '$wArtifact' -C "`$work"
cp -r '$wStage/config-template' "`$work/gittool/config-template"
tar czf "`$work/payload.tar.gz" -C "`$work" gittool
sed 's/\r`$//' '$wHeader' > "`$work/header.sh"
cat "`$work/header.sh" "`$work/payload.tar.gz" > '$wInstaller'
chmod +x '$wInstaller'
rm -rf "`$work"
echo "installer assembled"
"@ -replace "`r`n", "`n"

$script | wsl -d $WslDistro --exec bash -s
if ($LASTEXITCODE -ne 0) { throw 'WSL assembly failed' }
Write-Host "Done: $installer"
