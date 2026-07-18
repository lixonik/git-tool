<#
  GitTool setup: downloads IntelliJ IDEA Community (Apache 2.0), unpacks it and
  applies the GitTool configuration layer (git-only plugin set, isolated
  config/system dirs, launcher).

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\setup.ps1 [-InstallRoot D:\Apps\GitTool]
#>
param(
  [string]$InstallRoot = 'D:\Apps\GitTool'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$IdeVersion = '2025.2'
$ZipUrl = "https://download.jetbrains.com/idea/ideaIC-$IdeVersion.win.zip"
$ZipSha256 = 'b452f2a3678a1d7ec507bb1db1fda4318b4f5d0ee0f9d0e9e851d1092fb14e97'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Downloads = Join-Path $InstallRoot 'downloads'
$Dist = Join-Path $InstallRoot 'dist'
$ZipPath = Join-Path $Downloads "ideaIC-$IdeVersion.win.zip"

New-Item -ItemType Directory -Force $Downloads | Out-Null

if (-not (Test-Path $ZipPath) -or (Get-FileHash $ZipPath -Algorithm SHA256).Hash -ne $ZipSha256) {
  Write-Host "Downloading $ZipUrl (~1.5 GB)..."
  Invoke-WebRequest $ZipUrl -OutFile $ZipPath
}

$hash = (Get-FileHash $ZipPath -Algorithm SHA256).Hash
if ($hash -ne $ZipSha256) {
  throw "Checksum mismatch for ${ZipPath}: expected $ZipSha256, got $hash"
}
Write-Host 'Checksum OK.'

if (-not (Test-Path (Join-Path $Dist 'bin\idea64.exe'))) {
  Write-Host "Unpacking to $Dist..."
  if (Test-Path $Dist) { Remove-Item -Recurse -Force $Dist }
  Expand-Archive -Path $ZipPath -DestinationPath $Dist
}
Write-Host 'Distribution ready.'

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
  Write-Host 'Installing Classic UI plugin (until-build patched for 2025.2 release)...'
  $cuZip = Join-Path $env:TEMP 'classic-ui-252.zip'
  Invoke-WebRequest 'https://plugins.jetbrains.com/plugin/download?updateId=741561' -OutFile $cuZip -MaximumRedirection 5
  $cuTmp = Join-Path $env:TEMP 'cu252-setup'
  if (Test-Path $cuTmp) { Remove-Item -Recurse -Force $cuTmp }
  Expand-Archive $cuZip -DestinationPath $cuTmp
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $jar = Get-ChildItem $cuTmp -Recurse -Filter *.jar | Select-Object -First 1 -ExpandProperty FullName
  $z = [System.IO.Compression.ZipFile]::Open($jar, 'Update')
  $entry = $z.GetEntry('META-INF/plugin.xml')
  $sr = New-Object System.IO.StreamReader($entry.Open()); $xmlText = $sr.ReadToEnd(); $sr.Close()
  $patched = $xmlText -replace 'until-build="252\.13776\.\*"', 'until-build="252.*"'
  $entry.Delete()
  $newEntry = $z.CreateEntry('META-INF/plugin.xml')
  $sw = New-Object System.IO.StreamWriter($newEntry.Open()); $sw.Write($patched); $sw.Close()
  $z.Dispose()
  New-Item -ItemType Directory -Force $PluginsDir | Out-Null
  Copy-Item (Join-Path $cuTmp 'classic-ui') $PluginsDir -Recurse -Force
}

Write-Host "Done. Launch via $InstallRoot\GitTool.bat [path-to-repo]"
