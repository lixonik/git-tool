<#
  Applies the GitTool configuration layer to a from-source build of
  intellij-community ("IntelliJ IDEA Open Source", Apache 2.0).

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\setup-oss.ps1 `
      -ZipPath D:\Repos\intellij-community\out\idea-ce\artifacts\ideaIC-<build>.win.zip `
      [-InstallRoot D:\Apps\GitToolOSS]
#>
param(
  [Parameter(Mandatory = $true)][string]$ZipPath,
  [string]$InstallRoot = 'D:\Apps\GitToolOSS'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

if (-not (Test-Path $ZipPath)) { throw "Zip not found: $ZipPath" }

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Dist = Join-Path $InstallRoot 'dist'

if (-not (Test-Path (Join-Path $Dist 'bin\idea64.exe'))) {
  Write-Host "Unpacking $ZipPath to $Dist..."
  if (Test-Path $Dist) { Remove-Item -Recurse -Force $Dist }
  Expand-Archive -Path $ZipPath -DestinationPath $Dist
}

$ConfigDir = Join-Path $InstallRoot 'config'
New-Item -ItemType Directory -Force (Join-Path $ConfigDir 'options') | Out-Null

Copy-Item (Join-Path $RepoRoot 'config\disabled_plugins.txt') $ConfigDir -Force
Copy-Item (Join-Path $RepoRoot 'config\options\*') (Join-Path $ConfigDir 'options') -Force

$props = @"
idea.config.path=$($InstallRoot -replace '\\','/')/config
idea.system.path=$($InstallRoot -replace '\\','/')/system
idea.plugins.path=$($InstallRoot -replace '\\','/')/config/plugins
idea.log.path=$($InstallRoot -replace '\\','/')/system/log
idea.initially.ask.config=never
ide.no.platform.update=true
"@
Set-Content -Path (Join-Path $InstallRoot 'gittool.properties') -Value $props -Encoding ascii

Copy-Item (Join-Path $RepoRoot 'config\gittool.vmoptions') $InstallRoot -Force
Copy-Item (Join-Path $RepoRoot 'scripts\GitTool.bat') $InstallRoot -Force

$PluginsDir = Join-Path $ConfigDir 'plugins'
if (-not (Test-Path (Join-Path $PluginsDir 'classic-ui'))) {
  Write-Host 'Installing Classic UI plugin (262 line)...'
  $cuZip = Join-Path $env:TEMP 'classic-ui-262.zip'
  Invoke-WebRequest 'https://plugins.jetbrains.com/plugin/download?updateId=1102401' -OutFile $cuZip -MaximumRedirection 5
  New-Item -ItemType Directory -Force $PluginsDir | Out-Null
  Expand-Archive $cuZip -DestinationPath $PluginsDir -Force
}

Write-Host "Done. Launch via $InstallRoot\GitTool.bat [path-to-repo]"
