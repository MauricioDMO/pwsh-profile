# ========================================
# TAMAÑO DE ARCHIVOS / DIRECTORIOS
# ========================================

function Get-Size {
    param([string]$Path = ".")

    try {
        $ResolvedPath = Resolve-Path -Path $Path -ErrorAction Stop
    } catch {
        Write-Error "La ruta especificada no existe: $Path"
        return
    }

    $Folder = $ResolvedPath.ProviderPath
    $isFile = $false

    try {
        if (Test-Path -Path $Folder -PathType Leaf) { $isFile = $true }
    } catch {
        $isFile = $false
    }

    try {
        if ($isFile) {
            $file = Get-Item -LiteralPath $Folder -Force -ErrorAction SilentlyContinue
            $files = @()
            if ($file) { $files = @($file) }
            $sumBytes = if ($file) { $file.Length } else { 0 }
            $fileCount = if ($file) { 1 } else { 0 }
            $dirCount = 0
        } else {
            try {
                $files = @(Get-ChildItem -Path $Folder -Recurse -Force -File -ErrorAction SilentlyContinue)
            } catch {
                $files = @()
            }
            $sumBytes = ($files | Measure-Object -Property Length -Sum).Sum
            if (-not $sumBytes) { $sumBytes = 0 }
            $fileCount = if ($files) { $files.Count } else { 0 }
            try {
                $dirCount = @(Get-ChildItem -Path $Folder -Recurse -Force -Directory -ErrorAction SilentlyContinue).Count
            } catch {
                $dirCount = 0
            }
        }
    } catch {
        Write-Error "Error al calcular el tamaño de: $Folder"
        return
    }

    $hrTotal = Convert-Size $sumBytes
    $top = @()

    if ($fileCount -gt 0) {
        $top = $files | Sort-Object Length -Descending | Select-Object -First 5 | ForEach-Object {
            [PSCustomObject]@{
                FullName = $_.FullName
                Length   = $_.Length
                Name     = $_.Name
            }
        }
    }

    return [PSCustomObject]@{
        Path      = $Folder
        SizeBytes = $sumBytes
        Size      = $hrTotal
        Files     = $fileCount
        Folders   = $dirCount
        Top       = $top
        IsFile    = $isFile
    }
}

# Vista bonita
function size {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )

    $path = ( $Args -and $Args.Count -gt 0 -and -not [string]::IsNullOrEmpty($Args[0]) ) ? $Args[0] : '.'

    $info = Get-Size -Path $path
    if (-not $info) { return }

    try { $width = [Console]::WindowWidth } catch { $width = 60 }
    if (-not $width -or $width -lt 20) { $width = 60 }
    $line = ('─' * $width)

    Write-Host ""
    Write-Host $line -ForegroundColor DarkGray
    Write-Host ""
    Write-Host " Ruta   : " -NoNewline -ForegroundColor DarkCyan
    Write-Host "$($info.Path)" -ForegroundColor Gray
    Write-Host " Tamaño : " -NoNewline -ForegroundColor DarkCyan
    Write-Host "$($info.Size) ($($info.SizeBytes) bytes)" -ForegroundColor Green
    Write-Host " Archs  : " -NoNewline -ForegroundColor DarkCyan
    Write-Host "$($info.Files)" -ForegroundColor White -NoNewline
    Write-Host "    Carpetas:" -NoNewline -ForegroundColor DarkCyan
    Write-Host " $($info.Folders)" -ForegroundColor Yellow
    Write-Host ""

    if (-not $info.IsFile) {
        if ($info.Top -and $info.Top.Count -gt 0) {
            Write-Host "Top 5 archivos por tamaño:" -ForegroundColor Cyan
            foreach ($f in $info.Top) {
                $sizeStr = Convert-Size $f.Length
                try {
                    if ($f.FullName.StartsWith($info.Path, [System.StringComparison]::OrdinalIgnoreCase)) {
                        $relative = $f.FullName.Substring($info.Path.Length).TrimStart('\','/')
                        if ([string]::IsNullOrEmpty($relative)) { $relative = $f.Name }
                    } else {
                        $relative = $f.FullName
                    }
                } catch {
                    $relative = $f.FullName
                }
                Write-Host (" {0,9}  {1}" -f $sizeStr, $relative) -ForegroundColor Gray
            }
            Write-Host ""
        } else {
            Write-Host "No se encontraron archivos." -ForegroundColor Yellow
        }
    }

    Write-Host $line -ForegroundColor DarkGray
    Write-Host ""
}
