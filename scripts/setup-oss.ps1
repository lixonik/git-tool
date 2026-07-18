<#
  Assembles a runnable GitTool from a from-source build of intellij-community
  ("IntelliJ IDEA Open Source", Apache 2.0) and applies the configuration layer.

  The community installers build target skips the packaging step, so it leaves
  an unpacked OS distribution (dist.all + dist.win.x64) but no product-info.json,
  no bundled JBR, and no archive. This script stitches those together, extracts
  a JBR from the build download cache, synthesizes a product-info.json for the
  Java-side PathManager, and marks the install to launch via idea.bat.

  Usage:
    powershell -ExecutionPolicy Bypass -File scripts\setup-oss.ps1 `
      [-OutDir D:\Repos\intellij-community\out\idea-ce] `
      [-InstallRoot D:\Apps\GitToolOSS] [-JbrArchive <path to jbr_jcef*.tar.gz>]
#>
param(
  [string]$OutDir = 'D:\Repos\intellij-community\out\idea-ce',
  [string]$InstallRoot = 'D:\Apps\GitToolOSS',
  [string]$JbrArchive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

. (Join-Path $PSScriptRoot 'ClassicUi.ps1')

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Dist = Join-Path $InstallRoot 'dist'
$distAll = Join-Path $OutDir 'dist.all'
$distWin = Join-Path $OutDir 'dist.win.x64'
if (-not (Test-Path $distAll) -or -not (Test-Path $distWin)) {
  throw "Build output not found. Expected $distAll and $distWin (run installers.cmd first)."
}

Write-Host "Merging $distAll + $distWin -> $Dist ..."
New-Item -ItemType Directory -Force $Dist | Out-Null
robocopy $distAll $Dist /E /MT:16 /NFL /NDL /NJH /NJS /NP | Out-Null
robocopy $distWin $Dist /E /MT:16 /NFL /NDL /NJH /NJS /NP | Out-Null

# Bundle a JBR. Auto-discover the runtime archive from the build download cache.
if (-not (Test-Path (Join-Path $Dist 'jbr\bin\java.exe'))) {
  if (-not $JbrArchive) {
    $JbrArchive = Get-ChildItem (Join-Path (Split-Path $OutDir -Parent) '..\build\download') -Filter 'jbr_jcef-*windows-x64*.tar.gz' -ErrorAction SilentlyContinue |
      Select-Object -First 1 -ExpandProperty FullName
  }
  if (-not $JbrArchive -or -not (Test-Path $JbrArchive)) {
    throw 'JBR archive not found; pass -JbrArchive <path to jbr_jcef*.tar.gz>.'
  }
  Write-Host "Extracting JBR from $JbrArchive ..."
  $jbrTmp = Join-Path $env:TEMP 'gittool-jbr'
  if (Test-Path $jbrTmp) { Remove-Item -Recurse -Force $jbrTmp }
  New-Item -ItemType Directory -Force $jbrTmp | Out-Null
  tar -xzf $JbrArchive -C $jbrTmp
  $jbrHome = Get-ChildItem $jbrTmp -Recurse -Filter java.exe | Select-Object -First 1 | ForEach-Object { $_.Directory.Parent.FullName }
  Move-Item $jbrHome (Join-Path $Dist 'jbr')
}

# Synthesize product-info.json: the Java-side PathManager requires it to locate
# the install home. Boot classpath and JVM args are read straight from idea.bat.
$bat = Get-Content (Join-Path $Dist 'bin\idea.bat')
$jars = @(); foreach ($l in $bat) { if ($l -match 'lib/([^"]+\.jar)"?;"?\s*>>') { $jars += $Matches[1] } }
$baseArgs = @(
  '-Xbootclasspath/a:$IDE_HOME/lib/nio-fs.jar','-Djava.system.class.loader=com.intellij.util.lang.PathClassLoader',
  '-Didea.vendor.name=JetBrains','-Didea.paths.selector=IdeaIC2026.2','-Djna.boot.library.path=$IDE_HOME/lib/jna/amd64',
  '-Djna.nosys=true','-Djna.noclasspath=true','-Dpty4j.preferred.native.folder=$IDE_HOME/lib/pty4j','-Dio.netty.allocator.type=pooled',
  '-Dintellij.platform.runtime.repository.path=$IDE_HOME/modules/module-descriptors.dat','-Didea.platform.prefix=Idea',
  '-Dsplash=true','--enable-native-access=ALL-UNNAMED'
)
$opens = (($bat -join ' ') | Select-String -Pattern '--add-opens=[^\s"^]+' -AllMatches).Matches.Value | Select-Object -Unique
$productInfo = [ordered]@{
  name = 'IntelliJ IDEA'; version = '2026.2'; buildNumber = '262.SNAPSHOT'; productCode = 'IC'
  envVarBaseName = 'IDEA'; dataDirectoryName = 'IdeaIC2026.2'; svgIconPath = 'bin/idea.svg'; productVendor = 'JetBrains'
  launch = @([ordered]@{
    os = 'Windows'; arch = 'amd64'; launcherPath = 'bin/idea64.exe'; javaExecutablePath = 'jbr/bin/java.exe'
    vmOptionsFilePath = 'bin/idea64.exe.vmoptions'; bootClassPathJarNames = $jars
    additionalJvmArguments = ($baseArgs + $opens); mainClass = 'com.intellij.idea.Main'
  })
  bundledPlugins = @(); modules = @(); fileExtensions = @()
}
$productInfo | ConvertTo-Json -Depth 6 | Set-Content (Join-Path $Dist 'product-info.json') -Encoding utf8
Set-Content (Join-Path $Dist '.gittool-script-launcher') 'from-source build: launch via bin\idea.bat' -Encoding ascii

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
  # updateId 1102401 = Classic UI 262.8665.173. A from-source build carries a
  # SNAPSHOT build number and bundles the monolith client module, so drop the
  # since-build floor and the jetbrains.client incompatibility guard.
  Install-ClassicUi -PluginsDir $PluginsDir -UpdateId '1102401' `
    -Java (Join-Path $Dist 'jbr\bin\java.exe') -Repacker (Join-Path $PSScriptRoot 'PluginRepack.java') `
    -Patch {
      param($x)
      ($x -replace 'since-build="262\.8665"', 'since-build="262.1"') `
        -replace '(?m)^\s*<incompatible-with>.*?</incompatible-with>\s*\r?\n', ''
    }
}

Write-Host "Done. Launch via $InstallRoot\GitTool.bat [path-to-repo]"
