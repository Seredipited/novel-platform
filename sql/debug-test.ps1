$mysqlExe = "D:\MySQL\MySQL Server 8.0\bin\mysql.exe"
$sqlFile = "d:\IDEA\ssm\novel-platform\sql\init.sql"

Write-Host "=== Step 1: Re-init database UTF-8 ==="
$sqlContent = Get-Content $sqlFile -Raw -Encoding UTF8
$p = New-Object System.Diagnostics.Process
$p.StartInfo.FileName = $mysqlExe
$p.StartInfo.Arguments = "-u root -p112233 --default-character-set=utf8mb4"
$p.StartInfo.UseShellExecute = $false
$p.StartInfo.RedirectStandardInput = $true
$p.StartInfo.RedirectStandardOutput = $true
$p.StartInfo.RedirectStandardError = $true
$p.Start() | Out-Null
$sw = $p.StandardInput
$sw.Write($sqlContent)
$sw.Close()
$output = $p.StandardOutput.ReadToEnd()
$errOutput = $p.StandardError.ReadToEnd()
$p.WaitForExit()

if ($p.ExitCode -eq 0) {
    Write-Host "DB Init SUCCESS" -ForegroundColor Green
} else {
    Write-Host "DB Init FAILED: $errOutput" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Step 2: Test login ==="
try {
    $loginBody = '{"username":"admin","password":"123456"}'
    $loginResp = Invoke-RestMethod -Uri 'http://localhost:8081/user/login' -Method Post -Body $loginBody -ContentType 'application/json' -UseBasicParsing
    Write-Host "Login code: $($loginResp.code)"
    Write-Host "Token: $($loginResp.data.token.Substring(0,20))..."
    
    $token = $loginResp.data.token
    
    Write-Host ""
    Write-Host "=== Step 3: Test profile ==="
    try {
        $profileResp = Invoke-RestMethod -Uri 'http://localhost:8081/user/profile' -Method Get -Headers @{Authorization="Bearer $token"} -UseBasicParsing
        Write-Host "Profile: $($profileResp | ConvertTo-Json)"
    } catch {
        Write-Host "Profile ERROR: $($_.Exception.Message)" -ForegroundColor Red
        if ($_.Exception.Response) {
            $sr = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            Write-Host "Body: $($sr.ReadToEnd())" -ForegroundColor Red
        }
    }

    Write-Host ""
    Write-Host "=== Step 4: Test categories ==="
    try {
        $catResp = Invoke-RestMethod -Uri 'http://localhost:8082/novel/categories' -Method Get -UseBasicParsing
        Write-Host "Categories: $($catResp | ConvertTo-Json)"
    } catch {
        Write-Host "Categories ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host "Login ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
