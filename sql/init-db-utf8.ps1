$mysqlExe = "D:\MySQL\MySQL Server 8.0\bin\mysql.exe"
$sqlFile = "d:\IDEA\ssm\novel-platform\sql\init.sql"

Write-Host "=== Re-init database with UTF-8 ==="

$sqlContent = Get-Content $sqlFile -Raw -Encoding UTF8
$process = New-Object System.Diagnostics.Process
$process.StartInfo.FileName = $mysqlExe
$process.StartInfo.Arguments = "-u root -p112233 --default-character-set=utf8mb4"
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.RedirectStandardInput = $true
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.RedirectStandardError = $true
$process.Start() | Out-Null

# Write SQL content to stdin
$sw = $process.StandardInput
$sw.Write($sqlContent)
$sw.Close()

$output = $process.StandardOutput.ReadToEnd()
$errOutput = $process.StandardError.ReadToEnd()
$process.WaitForExit()

if ($process.ExitCode -eq 0) {
    Write-Host "Database init SUCCESS!" -ForegroundColor Green
} else {
    Write-Host "Database init FAILED!" -ForegroundColor Red
    Write-Host "STDERR: $errOutput" -ForegroundColor Yellow
}
