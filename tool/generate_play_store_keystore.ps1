param(
    [string]$Alias = "chotto-pathshala-upload",
    [string]$OutputDirectory = "."
)

$ErrorActionPreference = "Stop"
$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytool) {
    throw "Java keytool was not found. Install a JDK and add its bin folder to PATH."
}

$outDir = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $outDir | Out-Null
$keystorePath = Join-Path $outDir "upload-keystore.jks"
$base64Path = Join-Path $outDir "upload-keystore-base64.txt"

if (Test-Path $keystorePath) {
    throw "Keystore already exists at $keystorePath. Keep it safe; do not overwrite an existing upload key."
}

Write-Host "Create a strong password and store it in a trusted password manager."
Write-Host "When prompted for the key password, press Enter to reuse the keystore password."
& $keytool.Source -genkeypair -v -keystore $keystorePath -storetype JKS -keyalg RSA -keysize 4096 -validity 10000 -alias $Alias -dname "CN=Chotto Pathshala, OU=Mobile App, O=Chotto Pathshala, L=Dhaka, ST=Dhaka, C=BD"
if ($LASTEXITCODE -ne 0) {
    throw "keytool failed to create the upload keystore."
}

$bytes = [System.IO.File]::ReadAllBytes($keystorePath)
[System.IO.File]::WriteAllText($base64Path, [Convert]::ToBase64String($bytes), [System.Text.Encoding]::ASCII)
Write-Host ""
Write-Host "Created upload keystore: $keystorePath"
Write-Host "Created Base64 secret source: $base64Path"
Write-Host "Add the Base64 file contents and the two passwords as GitHub Actions secrets."
Write-Host "Never commit, email, or share the .jks file or its passwords."
