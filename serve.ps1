$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "Listening on http://localhost:8000/ - Press Ctrl+C to stop"
while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $path = $request.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    
    # Simple fix for paths
    $localPath = Join-Path (Get-Location).Path $path.Replace("/", "\")
    
    if (Test-Path $localPath -PathType Leaf) {
        try {
            $content = [System.IO.File]::ReadAllBytes($localPath)
            $response.ContentLength64 = $content.Length
            
            if ($localPath -match "\.html$") { $response.ContentType = "text/html" }
            elseif ($localPath -match "\.css$") { $response.ContentType = "text/css" }
            elseif ($localPath -match "\.js$") { $response.ContentType = "application/javascript" }
            elseif ($localPath -match "\.png$") { $response.ContentType = "image/png" }
            
            $response.OutputStream.Write($content, 0, $content.Length)
        } catch {
            $response.StatusCode = 500
        }
    } else {
        $response.StatusCode = 404
    }
    $response.Close()
}
