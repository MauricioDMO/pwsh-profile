# ========================================
# NODE.JS Y DESARROLLO
# ========================================

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

function ndev   { Invoke-NodeCommand "dev"   "Starting development server..." -ShowFiles }
function nbuild { Invoke-NodeCommand "build" "Building project..." }
function nstart { Invoke-NodeCommand "start" "Starting production server..." }

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

function ncheck {
    $commands = @(
        @{ Name = "Node.js"; Cmd = "node --version" }
        @{ Name = "npm";     Cmd = "npm --version"  }
        @{ Name = "pnpm";    Cmd = "pnpm --version" }
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

function ninit {
    Clear-Host
    Write-Host "Initializing new Node.js project..." -ForegroundColor Cyan
    pnpm init
}

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
