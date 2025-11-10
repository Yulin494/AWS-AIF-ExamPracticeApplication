# Android SDK 快速設置腳本

Write-Host "正在設置 Android SDK..." -ForegroundColor Green

# 建立 Android SDK 目錄
$androidHome = "$env:LOCALAPPDATA\Android\Sdk"
if (-not (Test-Path $androidHome)) {
    New-Item -ItemType Directory -Path $androidHome -Force
}

# 下載 Command Line Tools
$cmdlineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$downloadPath = "$env:TEMP\commandlinetools.zip"

Write-Host "下載 Android Command Line Tools..."
Invoke-WebRequest -Uri $cmdlineToolsUrl -OutFile $downloadPath

Write-Host "解壓縮..."
Expand-Archive -Path $downloadPath -DestinationPath "$androidHome\cmdline-tools" -Force

# 重新命名為 latest
$latestPath = "$androidHome\cmdline-tools\latest"
if (Test-Path $latestPath) {
    Remove-Item -Path $latestPath -Recurse -Force
}
Move-Item -Path "$androidHome\cmdline-tools\cmdline-tools" -Destination $latestPath

# 設置環境變數
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidHome, "User")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($currentPath -notlike "*$androidHome\platform-tools*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$androidHome\platform-tools;$androidHome\cmdline-tools\latest\bin", "User")
}

Write-Host "Android SDK setup complete!" -ForegroundColor Green
Write-Host "Please restart PowerShell and run: flutter doctor --android-licenses" -ForegroundColor Yellow
