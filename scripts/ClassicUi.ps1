<#
  Shared helper: download the Classic UI plugin from JetBrains Marketplace,
  patch its plugin.xml descriptor, and repackage the jar with the product's
  own runtime so IntelliJ's ImmutableZipFile reader accepts it.

  The repackaging must go through PluginRepack.java (run by jbr\bin\java.exe):
  .NET's ZipFile writes extra fields the platform's memory-mapped zip reader
  cannot parse, producing an "invalid plugin descriptor" load failure.
#>

function Install-ClassicUi {
  param(
    [Parameter(Mandatory)][string]$PluginsDir,
    [Parameter(Mandatory)][string]$UpdateId,
    [Parameter(Mandatory)][string]$Java,
    [Parameter(Mandatory)][string]$Repacker,
    [Parameter(Mandatory)][scriptblock]$Patch
  )

  if (-not (Test-Path $Java)) { throw "Runtime not found for repackaging: $Java" }

  $cuZip = Join-Path $env:TEMP "classic-ui-$UpdateId.zip"
  Invoke-WebRequest "https://plugins.jetbrains.com/plugin/download?updateId=$UpdateId" -OutFile $cuZip -MaximumRedirection 5

  $cuTmp = Join-Path $env:TEMP "cu-$UpdateId"
  if (Test-Path $cuTmp) { Remove-Item -Recurse -Force $cuTmp }
  Expand-Archive $cuZip -DestinationPath $cuTmp

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $jar = Get-ChildItem $cuTmp -Recurse -Filter *.jar | Select-Object -First 1 -ExpandProperty FullName
  $jarDir = Join-Path $env:TEMP "cu-$UpdateId-jar"
  if (Test-Path $jarDir) { Remove-Item -Recurse -Force $jarDir }
  [System.IO.Compression.ZipFile]::ExtractToDirectory($jar, $jarDir)

  $xmlPath = Join-Path $jarDir 'META-INF\plugin.xml'
  $xml = Get-Content $xmlPath -Raw
  $xml = & $Patch $xml
  [System.IO.File]::WriteAllText($xmlPath, $xml, (New-Object System.Text.UTF8Encoding($false)))

  Remove-Item $jar -Force
  & $Java $Repacker $jarDir $jar | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'PluginRepack failed' }

  New-Item -ItemType Directory -Force $PluginsDir | Out-Null
  $dest = Join-Path $PluginsDir 'classic-ui'
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item (Join-Path $cuTmp 'classic-ui') $PluginsDir -Recurse -Force
}
