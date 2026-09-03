# Lumina Events - Zero Dependency Local Development Web Server
param (
    [int]$Port = 3000
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"

try {
    $listener.Prefixes.Add($prefix)
    $listener.Start()
} catch {
    $Port = 3001
    $prefix = "http://localhost:$Port/"
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($prefix)
    $listener.Start()
}

Write-Host "==========================================================" -ForegroundColor DarkYellow
Write-Host " ALL ROUNDER.LK EVENTS & ADMIN PORTAL - LOCAL WEB SERVER" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor DarkYellow
Write-Host " Public Website:  $prefix" -ForegroundColor Cyan
Write-Host " Admin Console:   ${prefix}admin.html" -ForegroundColor Amber
Write-Host " All-in-One App:  ${prefix}all-rounder-app.html" -ForegroundColor Magenta
Write-Host " Credentials:     Username: admin  |  Password: allrounder2026" -ForegroundColor Green
Write-Host " Press Ctrl+C in this terminal to stop the server." -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor DarkYellow

# Open in default browser
Start-Process "${prefix}index.html"

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $rawUrl = $request.Url.LocalPath.TrimStart('/')
        if ([string]::IsNullOrWhiteSpace($rawUrl)) {
            $rawUrl = "index.html"
        }

        # Normalize path
        $filePath = Join-Path $scriptDir $rawUrl

        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $mime = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
            $response.ContentType = $mime

            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $notFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 Not Found</h1><p>File $rawUrl not found.</p>")
            $response.ContentLength64 = $notFoundBytes.Length
            $response.OutputStream.Write($notFoundBytes, 0, $notFoundBytes.Length)
        }

        $response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
