# ========================================
# CONFIGURACIÓN INICIAL
# ========================================

# Importar módulo de predicción de comandos
if (Get-Module -ListAvailable -Name CompletionPredictor) {
    Import-Module CompletionPredictor -ErrorAction SilentlyContinue
}

# Configurar fnm (Fast Node Manager) para cambio automático de versión de Node
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
}

# Inicializar oh-my-posh con el tema personalizado
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config $env:POSH_THEMES_PATH/froczh.omp.json | Invoke-Expression
}

# Configurar PSReadLine para autocompletado inteligente
if (Get-Module -ListAvailable -Name PSReadLine) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView -EditMode Windows
}

# Alias para PostgreSQL CLI
if (Get-Command pgcli -ErrorAction SilentlyContinue) { Set-Alias pg pgcli }

# ========================================
# FUNCIONES DE UTILIDAD
# ========================================

# Abre el directorio actual en el explorador de Windows
function e { Start-Process explorer . }

# Abre VS Code en el directorio actual o en la ruta especificada
function c { code ($args.Count -eq 0 ? '.' : $args[0]) }

# Convierte bytes a un formato legible (KB, MB, GB, TB)
function Convert-Size([long]$bytes) {
    if ($bytes -ge 1TB) { return ('{0:N2} TB' -f ($bytes / 1TB)) }
    if ($bytes -ge 1GB) { return ('{0:N2} GB' -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ('{0:N2} MB' -f ($bytes / 1MB)) }
    if ($bytes -ge 1KB) { return ('{0:N2} KB' -f ($bytes / 1KB)) }
    return ("{0} B" -f $bytes)
}

# Calcula el tamaño total de un directorio o archivo y retorna información detallada
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
            $files = Get-ChildItem -Path $Folder -Recurse -Force -File -ErrorAction SilentlyContinue
            $sumBytes = ($files | Measure-Object -Property Length -Sum).Sum
            if (-not $sumBytes) { $sumBytes = 0 }
            $fileCount = if ($files) { $files.Count } else { 0 }
            $dirCount = (Get-ChildItem -Path $Folder -Recurse -Force -Directory -ErrorAction SilentlyContinue).Count
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
                Length = $_.Length
                Name = $_.Name
            }
        }
    }

    return [PSCustomObject]@{
        Path = $Folder
        SizeBytes = $sumBytes
        Size = $hrTotal
        Files = $fileCount
        Folders = $dirCount
        Top = $top
        IsFile = $isFile
    }
}

# Muestra el tamaño de un directorio o archivo con formato bonito
# Uso: size [ruta]
function size {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $Args
    )

    if ($Args -and ($Args.Count -gt 0) -and -not [string]::IsNullOrEmpty($Args[0])) {
        $path = $Args[0]
    } else {
        $path = '.'
    }

    $info = Get-Size -Path $path
    if (-not $info) { return }

    try {
        $width = [Console]::WindowWidth
    } catch {
        $width = 60
    }
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

# ========================================
# NAVEGACIÓN RÁPIDA
# ========================================

# Rutas rápidas para acceso directo a carpetas comunes
$script:QuickPaths = @{
    core  = "$env:USERPROFILE\core"
    dev   = "$env:USERPROFILE\core\dev"
    uni   = "$env:USERPROFILE\core\university"
    work  = "$env:USERPROFILE\core\work"
    learn = "$env:USERPROFILE\core\learn"
}

function core { Set-Location $script:QuickPaths.core }
function dev { Set-Location $script:QuickPaths.dev }
function uni { Set-Location $script:QuickPaths.uni }
function work { Set-Location $script:QuickPaths.work }
function learn { Set-Location $script:QuickPaths.learn }

# ========================================
# SERVICIOS DEL SISTEMA
# ========================================

# Abre CornHub (sitio de memes de maíz)
function sexo { Start-Process https://cornhub.website/ }

# Habilita y arranca el servicio SSH Agent
function essh {
    $sshAgent = Get-Service ssh-agent
    if ($sshAgent.StartType -ne 'Manual') {
        $sshAgent | Set-Service -StartupType Manual
    }
    if ($sshAgent.Status -ne 'Running') {
        Start-Service ssh-agent
    }
}

# Carga el módulo Terminal-Icons para iconos en el listado de archivos
function ti {
    if (-not (Get-Module Terminal-Icons)) {
        Write-Host "Loading Terminal-Icons module..." -ForegroundColor Yellow
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            Import-Module Terminal-Icons
            $stopwatch.Stop()
            Write-Host "✅ Terminal-Icons loaded successfully in $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
        } catch {
            $stopwatch.Stop()
            Write-Host "❌ Failed to load Terminal-Icons after $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Red
            Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "✅ Terminal-Icons is already loaded" -ForegroundColor Green
    }
}

# ========================================
# NODE.JS Y DESARROLLO
# ========================================

# Ejecuta comandos de Node.js usando "node --run"
function Invoke-NodeCommand {
    param(
        [string]$Command,
        [string]$Description = "Running Node.js command",
        [switch]$ShowFiles
    )
    Write-Host $Description -ForegroundColor Cyan
    if (Test-Path "package.json" -PathType Leaf) {
        node --run $Command
    } else {
        Write-Host "No package.json found in current directory" -ForegroundColor Yellow
        if ($ShowFiles) {
            Get-ChildItem -Name | ForEach-Object { Write-Host "  $_" }
        }
    }
}

# Atajos para comandos comunes de Node.js
function ndev { Invoke-NodeCommand "dev" "Starting development server..." -ShowFiles }
function nbuild { Invoke-NodeCommand "build" "Building project..." }
function nstart { Invoke-NodeCommand "start" "Starting production server..." }

# Limpia node_modules y archivos lock
function nclean {
    Clear-Host
    Write-Host "Cleaning node_modules and lock files..." -ForegroundColor Cyan
    @("node_modules", "package-lock.json", "pnpm-lock.yaml", "yarn.lock") | ForEach-Object {
        if (Test-Path $_) { 
            Remove-Item -Recurse -Force $_ -ErrorAction SilentlyContinue
            Write-Host "  Removed: $_" -ForegroundColor Green
        }
    }
}

# Verifica versiones de Node, npm, pnpm e info del proyecto actual
function ncheck {
    $commands = @(
        @{ Name = "Node.js"; Cmd = "node --version" }
        @{ Name = "npm"; Cmd = "npm --version" }
        @{ Name = "pnpm"; Cmd = "pnpm --version" }
    )
    
    foreach ($cmd in $commands) {
        try {
            $version = Invoke-Expression $cmd.Cmd 2>$null
            Write-Host "$($cmd.Name): $version" -ForegroundColor Green
        } catch {
            Write-Host "$($cmd.Name): Not installed" -ForegroundColor Yellow
        }
    }
    
    if (Test-Path "package.json" -PathType Leaf) {
        Write-Host "`nCurrent project:" -ForegroundColor Cyan
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        Write-Host "  Name: $($pkg.name)" -ForegroundColor White
        Write-Host "  Version: $($pkg.version)" -ForegroundColor White
        if ($pkg.description) { Write-Host "  Description: $($pkg.description)" -ForegroundColor White }
    }
}

# Inicializa un nuevo proyecto de Node.js con pnpm
function ninit {
    Clear-Host
    Write-Host "Initializing new Node.js project..." -ForegroundColor Cyan
    pnpm init
}

# Inicia el servidor de desarrollo en un proceso separado
function Start-NodeDevServer {
    if (Test-Path "package.json" -PathType Leaf) {
        Start-Process node -ArgumentList "--run", "dev"
    } elseif (Test-Path "server/package.json" -PathType Leaf) {
        Push-Location server
        Start-Process node -ArgumentList "--run", "dev"
        Pop-Location
    } else {
        Write-Host "No package.json found" -ForegroundColor Yellow
    }
}

# Setup completo de desarrollo: abre VS Code, inicia servidor y navegador
function sdev {
    Clear-Host
    code .
    Start-Sleep -Milliseconds 500
    Start-NodeDevServer
    Start-Sleep -Milliseconds 500
    Start-Process http://localhost:3000
    Clear-Host
    Write-Host "✅ Development environment ready!" -ForegroundColor Green
}

# ========================================
# AYUDA Y COMANDOS DISPONIBLES
# ========================================

# Muestra todos los comandos personalizados disponibles organizados por categoría
function commands {
    $commandsTable = @{
        "Navigation" = @(
            "e       - Open current directory in Explorer"
            "c       - Open current directory in VS Code"
            "core    - Go to core directory"
            "dev     - Go to dev directory"
            "uni     - Go to university directory"
            "work    - Go to work directory"
            "learn   - Go to learn directory"
        )
        "Development" = @(
            "sdev    - Open VS Code + start dev server + open browser"
            "ndev    - Start dev server"
            "nbuild  - Build project"
            "nstart  - Start production server"
        )
        "Package Management" = @(
            "nclean  - Clean node_modules and lock files"
            "ninit   - Initialize new Node.js project"
            "ncheck  - Check Node versions and project info"
        )
        "System" = @(
            "ti      - Load Terminal-Icons module"
            "essh    - Enable SSH Agent"
            "size    - Shows the size of the dir"
        )
    }
    
    Write-Host "Commands:" -ForegroundColor DarkGreen
    foreach ($category in $commandsTable.Keys | Sort-Object) {
        Write-Host "`n$($category):" -ForegroundColor Yellow
        $commandsTable[$category] | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
    }
    Write-Host ""
}

# ========================================
# BANNER DE INICIO
# ========================================

# Centra texto en la consola
function Write-HostCentered {
    param (
        [string]$Text,
        [ConsoleColor]$ForegroundColor = 'White'
    )
    $width = [Console]::WindowWidth
    if ($Text.Length -ge $width) {
        Write-Host $Text -ForegroundColor $ForegroundColor
    } else {
        $padding = ' ' * [math]::Floor(($width - $Text.Length) / 2)
        Write-Host "$padding$Text" -ForegroundColor $ForegroundColor
    }
}

# Muestra el banner ASCII al iniciar la terminal
function Show-Name {
    $asciiArt = @(
        '░█▄█░█▀█░█░█░█▀▄░▀█▀░█▀▀░▀█▀░█▀█░█▀▄░█▄█░█▀█'
        '░█░█░█▀█░█░█░█▀▄░░█░░█░░░░█░░█░█░█░█░█░█░█░█'
        '░▀░▀░▀░▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀▀░░▀░▀░▀▀▀'
    )
    $asciiArt | ForEach-Object { Write-HostCentered $_ -ForegroundColor DarkGreen }
}

Show-Name