@echo off
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

powershell -NoProfile -Command ^
  "$dir = '%SCRIPT_DIR%';" ^
  "$userPath = [Environment]::GetEnvironmentVariable('Path', 'User');" ^
  "if ($userPath -split ';' | Where-Object { $_ -ieq $dir }) {" ^
  "  Write-Host \"Already in PATH: $dir\"" ^
  "} else {" ^
  "  $newPath = if ($userPath) { \"$userPath;$dir\" } else { $dir };" ^
  "  [Environment]::SetEnvironmentVariable('Path', $newPath, 'User');" ^
  "  Write-Host \"Added to PATH: $dir\";" ^
  "  Write-Host 'Restart your terminal for changes to take effect.'" ^
  "}"
