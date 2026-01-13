# ========================================
# NODE.JS Y DESARROLLO
# ========================================

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
        @{ Name = "npm"; Cmd = "npm --version" }
        @{ Name = "pnpm"; Cmd = "pnpm --version" }
        @{ Name = "bun"; Cmd = "bun --version" }
    )

    foreach ($cmd in $commands) {
        try {
            $version = Invoke-Expression $cmd.Cmd 2>$null
            Write-Host "$($cmd.Name): $version" -ForegroundColor Green
        }
        catch {
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

function nscripts {
    if (Test-Path "package.json" -PathType Leaf) {
        $pkg = Get-Content "package.json" | ConvertFrom-Json
        if ($pkg.scripts) {
            Write-Host "`nScripts in package.json:" -ForegroundColor Cyan
            
            $scripts = $pkg.scripts.PSObject.Properties
            $maxLen = ($scripts | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum

            foreach ($script in $scripts) {
                $name = $script.Name.PadRight($maxLen)
                Write-Host "  " -NoNewline
                Write-Host $name -ForegroundColor Green -NoNewline
                Write-Host " -> " -ForegroundColor Gray -NoNewline
                Write-Host $script.Value -ForegroundColor White
            }
            Write-Host ""
        }
        else {
            Write-Host "No scripts found in package.json." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "package.json not found in the current directory." -ForegroundColor Red
    }
}
