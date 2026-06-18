$mysqlExe = "D:\MySQL\MySQL Server 8.0\bin\mysql.exe"
$sqlFile = "d:\IDEA\ssm\novel-platform\sql\init.sql"

Write-Host "=== Initializing novel_platform database ==="

try {
    $result = Get-Content -Path $sqlFile -Raw | & $mysqlExe -u root -p112233 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Database init SUCCESS!" -ForegroundColor Green
    } else {
        Write-Host "Database init FAILED!" -ForegroundColor Red
        Write-Host $result
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Read-Host "Press Enter to exit"
