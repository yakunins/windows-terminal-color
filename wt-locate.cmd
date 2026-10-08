@echo off
:: Internal helper for wtc.cmd: make sure the `wt` alias works.
:: The WindowsApps alias (wt.exe) can point at an old, uninstalled Windows Terminal
:: version after an update ("The system cannot execute the specified program").
:: The real wt.exe under Program Files\WindowsApps can't be run directly (Access is denied),
:: so a stale alias is repaired by re-registering the installed package (Stable, else Preview).
:: Exit code: 0 = alias OK (or repaired), 1 = could not repair.
setlocal

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$alias = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\wt.exe';" ^
  "$pkg = Get-AppxPackage Microsoft.WindowsTerminal | Sort-Object Version -Descending | Select-Object -First 1;" ^
  "if (-not $pkg) { $pkg = Get-AppxPackage Microsoft.WindowsTerminalPreview | Sort-Object Version -Descending | Select-Object -First 1 };" ^
  "if (-not $pkg) { Write-Host 'wtc: Windows Terminal is not installed.'; exit 1 };" ^
  "$lines = fsutil reparsepoint query $alias | Where-Object { $_ -match '^[0-9a-f]{4}:' };" ^
  "$hex = $lines | ForEach-Object { $_.Substring(7, [Math]::Min(48, $_.Length - 7)) -split '\s+' } | Where-Object { $_ -match '^[0-9a-f]{2}$' };" ^
  "$text = [Text.Encoding]::Unicode.GetString([byte[]]($hex | ForEach-Object { [Convert]::ToByte($_, 16) }));" ^
  "if ($text -match '[A-Z]:\\[^\0]*?\\wt\.exe' -and (Split-Path $Matches[0]) -ieq $pkg.InstallLocation) { exit 0 };" ^
  "Write-Host ('wtc: wt alias is stale, re-registering ' + $pkg.PackageFullName + ' ...');" ^
  "try { Add-AppxPackage -Register (Join-Path $pkg.InstallLocation 'AppxManifest.xml') -DisableDevelopmentMode }" ^
  "catch {" ^
  "  Write-Host 'wtc: could not repair the wt alias (Windows Terminal is probably open).';" ^
  "  Write-Host 'wtc: close ALL Windows Terminal windows and run again, or toggle Settings > App execution aliases > Terminal.';" ^
  "  exit 1 };" ^
  "exit 0"
exit /b %errorlevel%
