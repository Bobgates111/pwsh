# PowerShell Simple Web Server
# This script creates a simple HTTP server to host files from a specified directory

param(
    [string]$Path = ".",
    [int]$Port = 8080
)

# Resolve the full path
$FullPath = Resolve-Path $Path

Write-Host "Starting PowerShell Web Server" -ForegroundColor Green
Write-Host "Serving files from: $FullPath" -ForegroundColor Cyan
Write-Host "Listening on: http://localhost:$Port/" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Create the HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

try {
    while ($true) {
        # Wait for a connection
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Get the requested path
        $relativePath = $request.Url.AbsolutePath.TrimStart('/')
        
        # Build the full file path
        if ([string]::IsNullOrEmpty($relativePath)) {
            $filePath = Join-Path $FullPath "index.html"
        } else {
            $filePath = Join-Path $FullPath $relativePath
        }
        
        # Check if file exists
        if (Test-Path $filePath -PathType Leaf) {
            # Read the file
            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
            
            # Determine content type based on extension
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = switch ($extension) {
                ".html" { "text/html" }
                ".htm" { "text/html" }
                ".css" { "text/css" }
                ".js" { "application/javascript" }
                ".json" { "application/json" }
                ".png" { "image/png" }
                ".jpg" { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".gif" { "image/gif" }
                ".svg" { "image/svg+xml" }
                ".ico" { "image/x-icon" }
                ".pdf" { "application/pdf" }
                ".txt" { "text/plain" }
                ".xml" { "application/xml" }
                default { "application/octet-stream" }
            }
            
            # Send the file
            $response.ContentType = $contentType
            $response.ContentLength64 = $fileBytes.Length
            $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 200 OK - $relativePath" -ForegroundColor Gray
        } elseif (Test-Path $filePath -PathType Container) {
            # If it's a directory, try to serve index.html or list directory contents
            $indexFile = Join-Path $filePath "index.html"
            if (Test-Path $indexFile -PathType Leaf) {
                $fileBytes = [System.IO.File]::ReadAllBytes($indexFile)
                $response.ContentType = "text/html"
                $response.ContentLength64 = $fileBytes.Length
                $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 200 OK - $relativePath/index.html" -ForegroundColor Gray
            } else {
                # Generate directory listing
                $files = Get-ChildItem $filePath | Select-Object Name, @{Name="Size";Expression={if($_.PSIsContainer){"<DIR>"}else{$_.Length}}}, LastWriteTime
                $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Directory listing for /$relativePath</title>
    <style>
        body { font-family: monospace; padding: 20px; }
        h1 { color: #333; }
        table { border-collapse: collapse; width: 100%; }
        td { padding: 5px 10px; border-bottom: 1px solid #eee; }
        tr:hover { background-color: #f5f5f5; }
        a { text-decoration: none; color: #0066cc; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Directory listing for /$relativePath</h1>
    <table>
        <tr><th>Name</th><th>Size</th><th>Last Modified</th></tr>
"@
                foreach ($file in $files) {
                    $link = if ($file.Name -eq "..") { ".." } else { $file.Name }
                    $html += "        <tr><td><a href=`"$link`">$($file.Name)</a></td><td>$($file.Size)</td><td>$($file.LastWriteTime)</td></tr>`n"
                }
                $html += @"
    </table>
</body>
</html>
"@
                $fileBytes = [System.Text.Encoding]::UTF8.GetBytes($html)
                $response.ContentType = "text/html"
                $response.ContentLength64 = $fileBytes.Length
                $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
                Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 200 OK - Directory listing: $relativePath" -ForegroundColor Gray
            }
        } else {
            # File not found
            $errorHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>404 Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        h1 { color: #e74c3c; }
    </style>
</head>
<body>
    <h1>404 - File Not Found</h1>
    <p>The requested file was not found on this server.</p>
</body>
</html>
"@
            $fileBytes = [System.Text.Encoding]::UTF8.GetBytes($errorHtml)
            $response.StatusCode = 404
            $response.ContentType = "text/html"
            $response.ContentLength64 = $fileBytes.Length
            $response.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 404 Not Found - $relativePath" -ForegroundColor Red
        }
        
        $response.Close()
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
finally {
    if ($listener) {
        $listener.Stop()
        $listener.Close()
        Write-Host "Server stopped." -ForegroundColor Yellow
    }
}
