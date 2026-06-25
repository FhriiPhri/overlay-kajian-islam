# PowerShell Lightweight HTTP Server for OBS Lower Third
$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

# In-memory state storage with default values
$global:state = '{"lowerThirdActive":false,"tickerActive":true,"speaker":"","title":"","quote":"","quoteRef":"","badge":"KAJIAN ISLAMI","isLive":true,"tickerText":"","tickerLabel":"INFO KAJIAN","timestamp":0}'
$global:lastOverlayActive = 0

try {
    $listener.Start()
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "    OBS LOWER THIRD WEB SERVER IS RUNNING" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "Server URL: http://localhost:$port" -ForegroundColor Yellow
    Write-Host "Control Panel: http://localhost:$port/control.html" -ForegroundColor Yellow
    Write-Host "OBS Overlay Source: http://localhost:$port/output.html" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "Membuka Control Panel di browser Anda..." -ForegroundColor Gray
    
    # Automatically open the control panel
    Start-Process "http://localhost:$port/control.html"
    
    Write-Host "Tekan Ctrl+C untuk menghentikan server." -ForegroundColor Yellow
    Write-Host ""

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/") { $urlPath = "/control.html" }
        
        # API Routes
        if ($urlPath -eq "/api/state") {
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            
            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.Close()
                continue
            }
            
            if ($request.HttpMethod -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd()
                $global:state = $body
                
                $response.StatusCode = 200
                $response.ContentType = "application/json"
                $buf = [System.Text.Encoding]::UTF8.GetBytes('{"status":"success"}')
                $response.ContentLength64 = $buf.Length
                $response.OutputStream.Write($buf, 0, $buf.Length)
            } else {
                # GET
                # Check if this is the overlay client polling
                $clientType = $request.QueryString["client"]
                $currentTime = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
                if ($clientType -eq "overlay") {
                    $global:lastOverlayActive = $currentTime
                }
                
                # Check if overlay was active in the last 2500ms
                $overlayConnected = ($currentTime - $global:lastOverlayActive) -lt 2500
                $overlayConnectedStr = if ($overlayConnected) { "true" } else { "false" }
                
                # Construct response JSON
                # We inject the overlayConnected status into the returned state object
                $cleanState = $global:state
                if ($cleanState.EndsWith("}")) {
                    $cleanState = $cleanState.Substring(0, $cleanState.Length - 1)
                    $responseJson = "$cleanState,`"overlayConnected`":$overlayConnectedStr}"
                } else {
                    $responseJson = $cleanState
                }

                $response.StatusCode = 200
                $response.ContentType = "application/json"
                $buf = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
                $response.ContentLength64 = $buf.Length
                $response.OutputStream.Write($buf, 0, $buf.Length)
            }
        } 
        # File serving
        else {
            $filePath = Join-Path (Get-Location) $urlPath
            
            if (Test-Path $filePath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                
                # Determine Content-Type
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $contentType = "application/octet-stream"
                if ($ext -eq ".html" -or $ext -eq ".htm") { $contentType = "text/html; charset=utf-8" }
                elseif ($ext -eq ".css") { $contentType = "text/css; charset=utf-8" }
                elseif ($ext -eq ".js") { $contentType = "text/javascript; charset=utf-8" }
                elseif ($ext -eq ".svg") { $contentType = "image/svg+xml; charset=utf-8" }
                elseif ($ext -eq ".png") { $contentType = "image/png" }
                elseif ($ext -eq ".jpg" -or $ext -eq ".jpeg") { $contentType = "image/jpeg" }
                
                $response.StatusCode = 200
                $response.ContentType = $contentType
                $response.ContentLength64 = $bytes.Length
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
                $response.ContentType = "text/plain"
                $buf = [System.Text.Encoding]::UTF8.GetBytes("404 File Not Found: $urlPath")
                $response.ContentLength64 = $buf.Length
                $response.OutputStream.Write($buf, 0, $buf.Length)
            }
        }
        $response.Close()
    }
}
catch {
    Write-Host "Error occurred: $_" -ForegroundColor Red
}
finally {
    $listener.Stop()
    Write-Host "Server stopped." -ForegroundColor Red
}