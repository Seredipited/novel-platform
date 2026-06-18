$mysqlExe = "D:\MySQL\MySQL Server 8.0\bin\mysql.exe"
Write-Host "=== Verify DB data ==="
$p = New-Object System.Diagnostics.Process
$p.StartInfo.FileName = $mysqlExe
$p.StartInfo.Arguments = "-u root -p112233 --default-character-set=utf8mb4 -e `"SELECT id, username, nickname FROM novel_user; SELECT id, name FROM novel_category; SELECT id, title, author FROM novel;`" novel_platform"
$p.StartInfo.UseShellExecute = $false
$p.StartInfo.RedirectStandardOutput = $true
$p.StartInfo.RedirectStandardError = $true
$p.Start() | Out-Null
$output = $p.StandardOutput.ReadToEnd()
$errOutput = $p.StandardError.ReadToEnd()
$p.WaitForExit()

Write-Host $output

Write-Host ""
Write-Host "=== Test login ==="
try {
    $loginBody = '{"username":"admin","password":"123456"}'
    $loginResp = Invoke-RestMethod -Uri 'http://localhost:8081/user/login' -Method Post -Body $loginBody -ContentType 'application/json' -UseBasicParsing
    Write-Host "Login: code=$($loginResp.code) msg=$($loginResp.message)"
    
    if ($loginResp.code -eq 200) {
        $token = $loginResp.data.token
        
        Write-Host ""
        Write-Host "=== Test profile ==="
        try {
            $profileResp = Invoke-RestMethod -Uri 'http://localhost:8081/user/profile' -Method Get -Headers @{Authorization="Bearer $token"} -UseBasicParsing
            Write-Host "Profile: $($profileResp | ConvertTo-Json)"
        } catch {
            Write-Host "Profile ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "=== Test categories (8082) ==="
        try {
            $catResp = Invoke-RestMethod -Uri 'http://localhost:8082/novel/categories' -Method Get -UseBasicParsing
            Write-Host "Categories: $($catResp | ConvertTo-Json)"
        } catch {
            Write-Host "Categories ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "=== Test via Gateway (8080) ==="
        try {
            $gwCatResp = Invoke-RestMethod -Uri 'http://localhost:8080/api/novel/categories' -Method Get -UseBasicParsing
            Write-Host "GW Categories: $($gwCatResp | ConvertTo-Json)"
        } catch {
            Write-Host "GW ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "Login ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
