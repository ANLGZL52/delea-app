# Google Play: upload (yukleme) imzasi
# Ciktilar: delea-upload-key.jks, key.properties (her ikisi de .gitignore'da veya dikkat)
#
# Calistirma (android/ icindeyken):
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\create_play_upload_keystore.ps1
#
# Sonra:  cd ..   (mobile)  ->  flutter build appbundle --release

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

$jks = Join-Path $root "delea-upload-key.jks"
if (Test-Path $jks) {
    $ok = Read-Host "delea-upload-key.jks var. Uzerine yazilsin mi? (E/H)"
    if ($ok -notin @("E", "e", "Y", "y")) { exit 0 }
    Remove-Item $jks -Force
}

$secure = Read-Host "Yeni keystore sifresi (guclu, tekrar gerekecek)" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
$pw2 = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)

$kt = $null
if (Get-Command keytool -ErrorAction SilentlyContinue) { $kt = "keytool" }
if (-not $kt -and $env:JAVA_HOME) {
    $c = Join-Path $env:JAVA_HOME "bin\keytool.exe"
    if (Test-Path $c) { $kt = $c }
}
if (-not $kt) {
    $c = "${env:ProgramFiles}\Android\Android Studio\jbr\bin\keytool.exe"
    if (Test-Path $c) { $kt = $c }
}
if (-not $kt) {
    Write-Error "keytool bulunamadi. Oracle JDK, Temurin JDK veya Android Studio JBR (bin) PATH / JAVA_HOME ile ekleyin."
    exit 1
}

$dname = "CN=DLA Plus, OU=Mobile, O=DLA, C=TR"
$gen = @(
    "-genkeypair", "-v",
    "-keystore", $jks,
    "-alias", "delea",
    "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
    "-storetype", "JKS",
    "-dname", $dname,
    "-storepass", $pw2,
    "-keypass", $pw2
)
& $kt @gen
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$props = Join-Path $root "key.properties"
$lines = @(
    "storePassword=$pw2",
    "keyPassword=$pw2",
    "keyAlias=delea",
    "storeFile=delea-upload-key.jks"
)
$lines | Set-Content -Path $props -Encoding UTF8

$pw2 = $null
Write-Host ""
Write-Host "Tamam: $jks"
Write-Host "Tamam: $props  (BUNU GIT'E EKLEME)"
Write-Host "Bir ustu klasore gec:  cd .."
Write-Host "AAB:  flutter build appbundle --release"
Write-Host ".jks ve sifreyi yedekle; kaybedersen Play yeni yukleme imzasi guncellemek zorundasin."
