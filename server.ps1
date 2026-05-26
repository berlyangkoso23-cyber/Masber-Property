$port = 3000
$path = (Get-Location).Path
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Listening on http://localhost:$port/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/") { $localPath = "/file.html" }
        $filePath = Join-Path $path $localPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length
            if ($filePath -match '\.html$') { $response.ContentType = "text/html" }
            elseif ($filePath -match '\.css$') { $response.ContentType = "text/css" }
            elseif ($filePath -match '\.js$') { $response.ContentType = "application/javascript" }
            
            $output = $response.OutputStream
            $output.Write($content, 0, $content.Length)
            $output.Close()
            Write-Host "200 OK - $localPath"
        } else {
            $response.StatusCode = 404
            $response.Close()
            Write-Host "404 Not Found - $localPath"
        }
    }
} catch {
    Write-Host "Server stopped."
} finally {
    $listener.Stop()
    $listener.Close()
}
